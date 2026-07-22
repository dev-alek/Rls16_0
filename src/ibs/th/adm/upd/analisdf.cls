 
 /*------------------------------------------------------------------------
    File        : analisdf
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Fri Feb 15 01:12:23 MSK 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.adm.upd.*.

block-level on error undo, throw.

class ibs.th.adm.upd.analisdf final: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
    {cmp/str-glbl.i class}  
    define variable obsrvdbObj as class observupd no-undo.
    
    define property TargetDBShm as integer no-undo 
    get.
    private set.
    
    define private property DelArea as logical no-undo
    get.
    set.

    define private property silent as logical no-undo
    get.
    set.

    define private property ActiveIndexAll as logical no-undo
    get.
    set.
    
    define property ModeUpd as character  no-undo
    get.
    set (iarg as character ):
       modeupd = iarg.
       DelArea = lookup("iscomp",iarg) ne 0.
       silent  = lookup("updblank",iarg) ne 0.
       ActiveIndexAll = lookup("OneDf",iarg) ne 0.
    end.
    
    define property Msg as character no-undo
    get.
    private set.
    
    define property PublisHandle as handle no-undo 
    get.
    set.

    define public property fileDF as character no-undo
    get.
    set.

    define public property noMessage as logical no-undo
    get.
    set.

    define stream Ostream.
    define stream sTrigger.
    define public variable mFileDf   as character no-undo.
    define public variable mUpdateTo as integer   no-undo.
    
    &scoped-define TABLE_ATTR AREA,LABEL,DESCRIPTION,DUMP-NAME,TABLE-TRIGGER,CAN-CREATE,CAN-DELETE,CAN-READ,CAN-WRITE,CAN-DUMP,CAN-LOAD
    &scoped-define FIELD_ATTR DESCRIPTION,FORMAT,INITIAL,LABEL,POSITION,MAX-WIDTH,COLUMN-LABEL,DECIMALS,HELP,ORDER,MANDATORY,NULL-ALLOWED,CASE-SENSITIVE,NOT-CASE-SENSITIVE,VIEW-AS,FORMAT-SA,HELP-SA,LABEL-SA,COLUMN-LABEL-SA,CAN-READ,CAN-WRITE,VALEXP,VALMSG,VALMSG-SA,EXTENT,INITIAL-SA
    &scoped-define INDEX_ATTR AREA,DESCRIPTION,UNIQUE,PRIMARY,INDEX-FIELD,WORD,inactive
    &scoped-define SEQUENCE_ATTR INITIAL,INCREMENT,CYCLE-ON-LIMIT,MIN-VAL,MAX-VAL
    
   constructor public analisdf (  ):
      obsrvdbObj = new observupd ().
    
     /* CurrDBShm   = obsrvdbObj:CurrDBShm.  
    CurrDB0Shm  = obsrvdbObj:CurrDB0Shm. 
    DbNum       = obsrvdbObj:DbNum.  */    
    TargetDBShm = obsrvdbObj:TargetDBShm.
      
   end constructor.

   destructor public analisdf ( ):
      delete object obsrvdbObj.
   end destructor.

   method public character  objExists  (input  ifolder as character,
                                     input  iType   as character  ):
      define variable vPureName  as character no-undo.
      define variable vFullPath as character no-undo.
      define variable vFileType as character no-undo.                                  
      file-information:file-name = ifolder.
      if index( file-information:file-type, iType ) > 0 then return file-information:full-pathname .
      file-information:file-name = "./" + ifolder.
      if index( file-information:file-type, iType ) > 0 then return file-information:full-pathname .

      return ? .

   end method.

 define stream sReadfile.
/*  define variable mMode as character no-undo.*/
  define variable mBuffer     as handle    no-undo.
  define variable mBufferName as character no-undo.
  define variable mName       as character no-undo.
  
  &glob prefixtt tt-
  &glob prefixfil f-
  &glob logicalfield логическое_поле 
  define temp-table {&prefixtt}TABLE
     field {&prefixfil}mode as char
     field {&prefixfil}Name as char
     field {&prefixfil}NewName as char
     
     field {&prefixfil}AREA as char
     field {&prefixfil}LABEL as char
     field {&prefixfil}CAN-CREATE as char
     field {&prefixfil}CAN-DELETE as char
     field {&prefixfil}CAN-READ as char
     field {&prefixfil}CAN-WRITE as char
     field {&prefixfil}CAN-DUMP as char
     field {&prefixfil}CAN-LOAD as char
     field {&prefixfil}DESCRIPTION as char
     field {&prefixfil}DUMP-NAME as char
     field {&prefixfil}TABLE-TRIGGER as char
     
     field {&prefixfil}localIndex as integer
     index {&prefixfil}localIndex {&prefixfil}localIndex
 .

   define temp-table {&prefixtt}FIELD
      field {&prefixfil}mode as char
      field {&prefixfil}Name as char
      field {&prefixfil}NewName as char
      
      field {&prefixfil}Table as char
      field {&prefixfil}Data-Type  as char
      
      field {&prefixfil}DESCRIPTION as char
      field {&prefixfil}FORMAT as char
      field {&prefixfil}INITIAL as char
      field {&prefixfil}INITIAL-SA as char
      
      field {&prefixfil}POSITION as char
      field {&prefixfil}MAX-WIDTH as char
      field {&prefixfil}DECIMALS as char
      field {&prefixfil}HELP as char
      field {&prefixfil}ORDER as char
      
      field {&prefixfil}MANDATORY as char
      field {&prefixfil}NULL-ALLOWED as char
      
      field {&prefixfil}CASE-SENSITIVE as char
      field {&prefixfil}NOT-CASE-SENSITIVE as char
      
      field {&prefixfil}VIEW-AS as char
      field {&prefixfil}FORMAT-SA as char
      field {&prefixfil}HELP-SA as char
      field {&prefixfil}LABEL as char
      field {&prefixfil}LABEL-SA as char
      field {&prefixfil}COLUMN-LABEL as char
      field {&prefixfil}COLUMN-LABEL-SA as char
      field {&prefixfil}CAN-READ as char
      field {&prefixfil}CAN-WRITE as char
      field {&prefixfil}VALEXP as char
      field {&prefixfil}VALMSG as char
      field {&prefixfil}VALMSG-SA as char
      field {&prefixfil}EXTENT as char
      
      field {&prefixfil}localIndex as integer 
     index {&prefixfil}localIndex {&prefixfil}localIndex
   .

define temp-table {&prefixtt}INDEX
      field {&prefixfil}mode as char
      field {&prefixfil}Name as char
      field {&prefixfil}NewName as char
      
      field {&prefixfil}Table as char
      field {&prefixfil}AREA as char
      field {&prefixfil}DESCRIPTION as char
      field {&prefixfil}UNIQUE as char
      field {&prefixfil}PRIMARY as char
      field {&prefixfil}INDEX-FIELD as char
      field {&prefixfil}Word as char
      field {&prefixfil}localIndex as integer
      field {&prefixfil}inactive as Char
     index {&prefixfil}localIndex {&prefixfil}localIndex
      
   .
   define temp-table {&prefixtt}SEQUENCE
      field {&prefixfil}mode as char
      field {&prefixfil}Name as char
      field {&prefixfil}NewName as char
      
      field {&prefixfil}INITIAL as char
      field {&prefixfil}INCREMENT as char
      field {&prefixfil}CYCLE-ON-LIMIT as char
      field {&prefixfil}MIN-VAL as char
      field {&prefixfil}MAX-VAL as char
      
      field {&prefixfil}localIndex as integer
     index {&prefixfil}localIndex {&prefixfil}localIndex
   .
  method public logical createDF (iCurrDBShm as integer):
     return createDF(iCurrDBShm,TargetDBShm).
  end method.   
  
  method public logical createDF (iCurrDBShm as integer, iTargetDBShm as integer):
     define variable vi as integer no-undo.
     define variable vFileDf as character no-undo.
     define variable vFlagDf as logical no-undo.
     
     block-read:
     do  vi = iCurrDBShm + 1 to minimum(iTargetDBShm,TargetDBShm):
        if not obsrvdbObj:m-upd-list-df[vi    ] begins "proc:"
        then do:
           vFlagDf = yes.
           vFileDf   = obsrvdbObj:m-upd-list-df[vi].
           if vFileDf begins "only:"
           then
              vFileDf = substring(vFileDf,6).
           if readDF(vFileDf)
           then
              return no.
        end.
        else do:
           mFileDf   = obsrvdbObj:m-upd-list-df[vi    ].
           if mFileDf begins "only:"
           then
              mFileDf = substring(mFileDf,6).
           mUpdateTo = vi.
           return yes. 
        end.
        if     vi >= TargetDBShm 
           or  obsrvdbObj:m-upd-list-df[vi    ] begins "proc:"
           or  obsrvdbObj:m-upd-list-df[vi + 1] begins "proc:"               
           or  obsrvdbObj:m-upd-list-df[vi    ] begins "only:"
           or  obsrvdbObj:m-upd-list-df[vi + 1] begins "only:"               
           
         then 
            leave block-read.  
     end.
     
     if vi > minimum(iTargetDBShm,TargetDBShm) 
     then 
        vi = minimum(iTargetDBShm,TargetDBShm).
     if mFileDf begins "proc:"
     then
        return yes.
     define variable VavailVer as logical no-undo.
     for each {&prefixtt}FIELD where {&prefixfil}Name       = '"reserve1-char"'
                                 and {&prefixfil}Table      = '"db"'
     :
        {&prefixfil}initial    = '"' + string(vi) + '"' .
        VavailVer = yes.
     end.
     if not VavailVer
     then do:
        create {&prefixtt}FIELD.
        assign
          {&prefixfil}mode       = "UPDATE"   /* дополнительные кавычки нужны для выгрузки DF*/
          {&prefixfil}Name       = '"reserve1-char"'
          {&prefixfil}Table      = '"db"'
          {&prefixfil}initial    = '"' + string(vi) + '"' 
          {&prefixfil}localIndex = 1
        .
     end.
     vFileDf = substitute ("&1_&2_&3.df","update",iCurrDBShm,vi).
     dumpTable(vFileDf).
     mFileDf   = objExists(vFileDf,"f").
     mUpdateTo = vi.
     return yes.   
  end.
  
  method public character  addDFNumUpd (iFileDf as character, num as integer ):
     define variable Vi          as integer no-undo.
     define variable vfiledf     as character no-undo.
     define variable vSTR        as character no-undo.
     define variable vFileDf_new as character no-undo.
     define variable vFirst      as logical no-undo init yes.
     
     
     do vi = 1 to num-entries(iFileDf):
         vFileDf_new = replace( iFileDf, "~\", "~/" ).
         vFileDf_new = entry( num-entries( vFileDf_new, "~/" ), vFileDf_new, "~/" ).
         entry(1,vFileDf_new, ".") =  entry(1,vFileDf_new, ".") + "_" + string (num).
          
         
         vfiledf = search (entry(vi,iFileDf)).
         output stream Ostream to value(vFileDf_new).
         input STREAM sReadfile FROM  VALUE(vfiledf).
         block-file:
         repeat:
             import stream sReadfile unformatted vSTR.
             if      trim (vstr) eq "."
                and vFirst             
             then do:
                vFirst = no.
                put stream Ostream unformatted  'UPDATE FIELD "reserve1-char" OF "db"' skip '  INITIAL "' + string(num) + '"' skip(1).
               
             end.
             if trim(vstr) eq ""
             then
                put stream Ostream unformatted      skip(1) .
             else  
                put stream Ostream unformatted trim (replace (vstr,"  "," ")) skip .
         end.
         
         input STREAM sReadfile CLOSE.
         output stream Ostream close.
         entry(vi,iFileDf) = vFileDf_new.
      end.
     return iFileDf.
  end.   
      
  method public logical readDF (iFileDf as character ):
      define variable vSTR as character no-undo.
      define variable vI as integer no-undo.
      define variable vfiledf as character no-undo.
      
      do vi = 1 to num-entries(iFileDf):
         vfiledf = search (entry(vi,iFileDf)).
         if vfiledf eq ?
         then do:
            Msg = substitute("Не найден файл &1" , entry(vi,iFileDf)).
            putmes(msg).
            
            return yes.
         end.
         input STREAM sReadfile FROM  VALUE(vfiledf).
         block-file:
         repeat:
             import stream sReadfile unformatted vSTR.
             if trim (vstr) eq "." then leave block-file.
             if parsString(vSTR)
             then 
                return yes.
         end.
         input STREAM sReadfile CLOSE.
      end.
      finally:
      if valid-handle (mBuffer)
         then
            delete object mBuffer.
      end finally.      
  end method.
  
     define variable mposih         as integer no-undo init 1.
   method private logical parsString ( iStr as character ):
      
      define variable vStrTmp     as character no-undo. 
      
      
      define variable vTableWhere as character no-undo.
      define variable vFieldName  as character no-undo.
      define variable vOptionalWhere as character no-undo.
      define variable vMode          as character no-undo.
      define variable vtarget        as character no-undo.
      define variable vStr           as character no-undo.
      define variable vStr1          as character no-undo.
      
      define variable vSdvig         as integer no-undo.
      define variable VPrimary       as logical no-undo.
      define variable vFilePos       as integer no-undo.
      
      iStr = trim (replace (istr,"  "," ")).
      if istr eq "" then return no.
      vMode = entry(1,istr, " ").
      
      if can-do("add,update,drop,rename", vMode)
      then do:
         mBufferName = entry(2,istr, " ") no-error.
         if error-status:error
         then do:
            msg = substitute("Ошибка структуре df файла не задан объект для метода &1", vMode).
            putmes(msg).
            return yes.
         end.
         if mBufferName eq "PRIMARY"
         then do:  
             mBufferName = entry(3,istr, " ") no-error.
             if error-status:error
             then do:
                msg = substitute( "Ошибка структуре df файла не задан объект для метода &1", vMode).
                putmes(msg).
                return yes.
             end.
             assign 
                vSdvig   = 1
                VPrimary = yes 
                .
         end.
         if valid-handle( mBuffer)
         then 
            delete object mBuffer.
            
         create buffer mBuffer for table "{&prefixtt}" + mBufferName no-error.
         if error-status:error
         then do:
            msg = substitute( "Не известный буфер &1" , "{&prefixtt}" + mBufferName).
                 
            putmes(msg).
            return yes.
         end.

         mName = entry(3 + vSdvig,istr, " ") no-error.
         if error-status:error
         then do: 
            msg = substitute( "Ошибка структуре df файла не задан объект для метода &1  для таблицы &2" ,vMode , "{&prefixtt}" + mBufferName).
            putmes(msg).
            return yes.
         end.
         if    mBufferName eq "field"
         then do:
            vTableWhere = if vMode eq "rename" then entry(5,istr, " ") else entry(5 + vSdvig,istr, " ") no-error.
            if error-status:error
            then do: 
               msg = substitute( "Ошибка структуре df файла не задан таблица для &1 &2", mBufferName, mName).
               putmes(msg).
               return yes.
            end.
            else do:
               if vMode eq "rename" then vtarget = entry(7,istr, " ").
               vOptionalWhere = substitute (" and {&prefixtt}&1.{&prefixfil}table eq '&2'",mBufferName,vTableWhere).
               
            end.   
         end.
         else if mBufferName eq "index"
         then do:
            vTableWhere = if vMode eq "rename" then entry(7,istr, " ") else entry(5 + vSdvig,istr, " ") no-error.
            if error-status:error
            then do: 
               msg = substitute( "Ошибка структуре df файла не задан таблица для &1 &2", mBufferName, mName).
               putmes(msg).
               return yes.
            end.
            else do:
               if vMode eq "rename" then vtarget = entry(5,istr, " ").
               vOptionalWhere = substitute (" and {&prefixtt}&1.{&prefixfil}table eq '&2'",mBufferName,vTableWhere).
               
            end.   
         end.
         else
            vOptionalWhere = "".
         vOptionalWhere = substitute ("where {&prefixtt}&1.{&prefixfil}Name eq '&2' &3",mBufferName,mName,vOptionalWhere).
         mBuffer:find-last(vOptionalWhere, no-lock) no-error.
         if mBuffer:available 
         then do:
            if     vMode                     eq "rename"
               and mBuffer::{&prefixfil}mode eq "add"
            then do:
               if mbuffername eq "table"
               then do:
                  ChangeTable(mBuffer::{&prefixfil}Name , entry(5,istr, " ")).
                  mBuffer::{&prefixfil}Name = entry(5,istr, " ").
               end.
               else
                  mBuffer::{&prefixfil}Name = vtarget.
                  return no.
            end.    
            else if      mBuffer::{&prefixfil}mode eq "rename" 
                      or (    vMode eq "rename"
                          and vmode eq "update")
            then do:
               mposih = mBuffer::{&prefixfil}localIndex + 1.
               mBuffer:buffer-release ().
            end.    
            else if vmode eq "add" 
            then do:
               if mBuffer::{&prefixfil}mode eq "drop"
               then do:
                  mposih = mBuffer::{&prefixfil}localIndex + 1.
                  mBuffer:buffer-release ().
               end.
               else do: 
                  msg = substitute( "Ошибка структуре df файла объект создан рание &1 &2 &3 &4", vmode, mBufferName, mName, vTableWhere).
                  putmes(msg).
                  return yes.
               end.
            end.
            else if vmode eq "drop"
            then do:
               if mBuffer::{&prefixfil}mode eq "add" or mBuffer::{&prefixfil}mode eq "update"
               then do:
                  if mbuffername eq "table"
                  then do:
                     for each {&prefixtt}FIELD where {&prefixtt}FIELD.{&prefixfil}Table eq mBuffer::{&prefixfil}name:
                        delete {&prefixtt}FIELD.
                     end.
                     for each {&prefixtt}index where {&prefixtt}index.{&prefixfil}Table eq mBuffer::{&prefixfil}name:
                        delete {&prefixtt}index.
                     end.
                  end.
                  if mBuffer::{&prefixfil}mode eq "add"
                  then do:
                     mBuffer:buffer-delete ().
                     return no.
                  end.
                  else
                     mBuffer:buffer-delete ().
               end.
               else
                  mBuffer::{&prefixfil}mode = vmode.
             
            end.
                
         end.
         if not mBuffer:available 
         then do:
            mBuffer:buffer-create ().
            mBuffer::{&prefixfil}mode       = vmode.
            mBuffer::{&prefixfil}Name       = mName.
            mBuffer::{&prefixfil}localIndex = mposih.
            if vMode eq "rename" 
            then 
               mBuffer::{&prefixfil}NewName = if    mbuffername eq "table"
                                                 or mbuffername eq "index"
                                              then entry(5,istr, " ") 
                                              else entry(7,istr, " ").
         end.
         if VPrimary 
         then
           mBuffer:buffer-field("{&prefixfil}PRIMARY"):BUFFER-VALUE () = "{&logicalfield}".
         if    mBufferName eq "field"
            or mBufferName eq "index"
         then 
            mBuffer::{&prefixfil}table = vTableWhere.
         if    mBufferName eq "field"
            and vMode ne "rename"
         then do: 
            mBuffer::{&prefixfil}Data-Type = entry(7,istr, " ") no-error.
            if     error-status:error
               and vMode eq "add"
            then do: 
               msg = substitute( "Ошибка структуре df файла не задан таблица для &1 &2", mBufferName, mName).
               putmes(msg).
               return yes. 
            end.
         end.
      end.             
      else do: /* can-do("add,update,drop", vStrTmp) */
         if    mBufferName eq "table" and can-do("{&TABLE_ATTR}",trim(vMode,'"'))
            or mBufferName eq "field" and can-do("{&FIELD_ATTR}",trim(vMode,'"'))
            or mBufferName eq "INDEX" and can-do("{&INDEX_ATTR}",trim(vMode,'"'))          
            or mBufferName eq "SEQUENCE" and can-do("{&SEQUENCE_ATTR}",trim(vMode,'"'))
         then do:
               if     ActiveIndexAll
                  and mBufferName eq "INDEX" and can-do("inactive",trim(vMode,'"'))
               then
                  return no.
               vFieldName = "{&prefixfil}" + vMode no-error.
               if error-status:error
               then do:
                  msg = substitute( "Ошибка структуре df  объекта &1 &2 нет поля в таблице &3", mBufferName, mName, "{&prefixfil}" + vMode). 
                  putmes(msg).
                  return yes.
               end.
        /*       if vmode eq "inactive"
               then do:
                  msg = substitute( "Ошибка добавляется не активный индекс &1 таблице &2",  mName /* , {&prefixtt}index.{&prefixfil}table*/ ). 
                  putmes(msg).
                  message msg view-as alert-box.
                  return yes.
               end.  */
               define variable vval as character no-undo.
               vval = trim(
                                                                  (if can-do("INDEX-FIELD,TABLE-TRIGGER" ,vmode)  
                                                                  then mBuffer:buffer-field(vFieldName):BUFFER-VALUE () + {&delim-par}
                                                                  else "")
                                                                + trim (substring (istr,length(vMode) + 2)) 
                                                                ,{&delim-par} ).
               if trim(vMode,'"') = "DESCRIPTION" then
               do: /* обработка для DESCRIPTION многострочного значения */
                 BLOCK_DESC:
                 repeat:
                   vFilePos = seek(sReadfile).
                   import stream sReadfile unformatted vStr.
                   vStr1 = entry(1, trim(vStr), " ").
                   if mBufferName eq "table" and can-do("{&TABLE_ATTR}",trim(vStr1,'"'))
                      or mBufferName eq "field" and can-do("{&FIELD_ATTR}",trim(vStr1,'"'))
                      or mBufferName eq "INDEX" and can-do("{&INDEX_ATTR}",trim(vStr1,'"')) then
                   do:
                     seek stream sReadfile to vFilePos.
                     leave BLOCK_DESC.   
                   end.
                   else
                   do:
                     vval = vval + "~n" + vStr.
                   end.
                 end. 
               end.
               mBuffer:buffer-field(vFieldName):BUFFER-VALUE () = vval   no-error.  
                
               if mBuffer:buffer-field(vFieldName):BUFFER-VALUE () eq "" 
               then 
                  mBuffer:buffer-field(vFieldName):BUFFER-VALUE () = "{&logicalfield}".
               if error-status:error
               then do: 
                  msg = substitute( "2 Ошибка структуре df  объекта &1 &2", mBufferName, mName). 
                  putmes(msg).
                  return yes.
               end.
               if vMode eq "NULL-ALLOWED"
               then
                  mBuffer:buffer-field("{&prefixfil}MANDATORY"):BUFFER-VALUE () = "".
               else if vMode eq "MANDATORY"
               then
                  mBuffer:buffer-field("{&prefixfil}NULL-ALLOWED"):BUFFER-VALUE () = "".
               else if vMode eq "NOT-CASE-SENSITIVE"
               then
                  mBuffer:buffer-field("{&prefixfil}CASE-SENSITIVE"):BUFFER-VALUE () = "".
               else if vMode eq "CASE-SENSITIVE"
               then
                  mBuffer:buffer-field("{&prefixfil}NOT-CASE-SENSITIVE"):BUFFER-VALUE () = "".
         end.       
         else do:
            msg = substitute( "Ошибка структуре df  объекта &1 &2 неизвестное выражение &3",mBufferName, mName, vMode). 
            putmes(msg).
            return yes.
         end.
         
      end.     /* can-do("add,upddate,drop", vStrTmp) */
   
   end method.
   
   method public void dumpTable(ifile  as character):
      if fileDF <> "" then 
      do:
          iFile = fileDF.
      end.
      else
      do:
        output stream Ostream to value(ifile).
        output stream Ostream close.
      end.
      find first {&prefixtt}Table no-error.
      if available {&prefixtt}Table
      then
         dumpOneTable(ifile,buffer {&prefixtt}Table:handle ).
      find first {&prefixtt}field no-error.
      if available {&prefixtt}field
      then
         dumpOneTable(ifile,buffer {&prefixtt}field:handle ).
      find first {&prefixtt}index no-error.
      if available {&prefixtt}index
      then
         dumpOneTable(ifile,buffer {&prefixtt}index:handle ).
      find first {&prefixtt}SEQUENCE no-error.
      if available {&prefixtt}SEQUENCE
      then
         dumpOneTable(ifile,buffer {&prefixtt}SEQUENCE:handle ).
      if fileDF = "" then 
      do:
          output stream Ostream to value(ifile) append.
          put stream Ostream unformatted "." skip "PSC" skip "cpstream=1251" skip "." skip .
          output stream Ostream close.
      end.           
   end.
   
   method private void dumpOneTable(ifile  as character,
                                   iBuffer as  handle):
   
   define var vItm   as int64  no-undo.
   define var vJ   as int64  no-undo.
   define var vField as handle   no-undo.

   define var vQuery  as handle no-undo.
   define var vBuffer as handle no-undo.
   define variable vTxt       as character no-undo.
   define variable vFieldName as character no-undo.
   define variable vFieldPref as integer   no-undo.
   
   vBuffer = iBuffer.
   output stream Ostream to value(ifile) append.
   do transaction:
   create query vQuery.
   vQuery:add-buffer(vBuffer).
   def var vPredicate as char no-undo.
/*   vPredicate = "for EACH " + vBuffer:name + " BY "  + vBuffer:name + ".{&prefixfil}ORDER".*/
/*   run gbl/inidebug.p.*/
   vPredicate = "for EACH " + vBuffer:name + if vBuffer:name = "{&prefixtt}FIELD" then " BY INT("  + vBuffer:name + ".{&prefixfil}ORDER)" else "".
   if not vQuery:query-prepare(vPredicate) then  do: msg = substitute( "ERROR 1 ", error-status:get-message(1)).  message msg view-as alert-box. end.
   if not vQuery:query-open()then  do: msg = substitute( "ERROR 2 ", error-status:get-message(1)).  message msg view-as alert-box. end.
   vQuery:get-first().
   if vBuffer:available
   then do: 
      
      vFieldPref = length("{&prefixfil}") + 1. 
      do while vBuffer:available:
         
         vtxt = if vBuffer:name eq "{&prefixtt}field" 
             then substitute ("&1 FIELD &2 OF &3 &4&5",
                              vBuffer::{&prefixfil}mode,
                              vBuffer::{&prefixfil}name,
                              vBuffer::{&prefixfil}table,
                              if vBuffer::{&prefixfil}mode eq "rename" then " TO " + vBuffer::{&prefixfil}NewName else "",
                              if vBuffer::{&prefixfil}Data-Type ne "" then "AS " + vBuffer::{&prefixfil}Data-Type else "")
             else if vBuffer:name eq "{&prefixtt}index" 
             then substitute ("&1 INDEX &2&3 ON &4",
                              vBuffer::{&prefixfil}mode,
                              vBuffer::{&prefixfil}name,
                              if vBuffer::{&prefixfil}mode eq "rename" then " TO " + vBuffer::{&prefixfil}NewName  else "",
                              if vBuffer::{&prefixfil}mode eq "rename" then vBuffer::{&prefixfil}table else vBuffer::{&prefixfil}table)
             else substitute ("&1 &2 &3&4",
                              vBuffer::{&prefixfil}mode,
                              substring(vBuffer:name,length("{&prefixtt}") + 1),
                              vBuffer::{&prefixfil}name,
                              if vBuffer::{&prefixfil}mode eq "rename" then " TO " + vBuffer::{&prefixfil}NewName else ""
                              ).
         put stream Ostream unformatted vtxt skip.
         do vItm = 1 to vBuffer:num-fields:
            vField = vBuffer:buffer-field(vItm).
            vFieldName = substring(vField:name,vFieldPref).
            
            if not can-do("mode,name,newname,table,Data-Type,localindex" + (if DelArea then ",area" else "") ,vFieldName)
            then do:
               
               do vj = 1 to if vField:buffer-value eq ? then 1 else num-entries(vField:buffer-value,{&delim-par}):
                  define variable vValue as character no-undo.
                  vValue = entry(vj,vField:buffer-value,{&delim-par}).
                  if vValue eq "{&logicalfield}" then vValue = "". 
                  put stream Ostream unformatted substitute ('  &1 &2',vFieldName,vValue) skip.
               end.    
            end.
         end.
         put stream Ostream unformatted skip(1).
         vQuery:get-next().
      end.
   end.
   finally :
     if valid-handle(vQuery) then
     do:
       vQuery:query-close().
       delete object vQuery.
     end.
     output stream Ostream close.
   end finally .

   end.
end method.
method public logical CheckTable(ifile  as character):
      define variable vOk as logical no-undo.
      define variable oOK as logical no-undo.
      oOK = CheckOneTable(temp-table {&prefixtt}Table:handle ).
      vOk = CheckOneTable(temp-table {&prefixtt}field:handle ).
      oOK = oOK and vOk.  
      vOk = CheckOneTable(temp-table {&prefixtt}index:handle ).
      oOK = oOK and vOk.
      vOk = CheckOneTable(temp-table {&prefixtt}SEQUENCE:handle ).
      oOK = oOK and vOk.
      
      if not oOK
      then
         dumpTable(ifile).
      return oOK.                                
   end.
method private logical CheckOneTable(iTable as  handle):
   
   define buffer buf{&prefixtt}TABLE for {&prefixtt}TABLE.
   define var vItm   as int64  no-undo.
   define var vJ   as int64  no-undo.
   define var vField as handle   no-undo.

   define var vQuery  as handle no-undo.
   define var vBuffer as handle no-undo.
   define var vBufferDB as handle no-undo.
   define variable vTxt       as character no-undo.
   define variable vFieldName as character no-undo.
   define variable vFieldPref as integer   no-undo.
   define variable vFieldValue as character no-undo.
   define variable vBufferName as character no-undo.
   define variable vWhere      as character no-undo.
   define variable vOk     as logical no-undo.
   define variable oOkl     as logical no-undo init yes.
   define variable verror  as logical no-undo.
   define variable vFlagEQ as logical no-undo.
   define variable vCheckField as logical no-undo.
   
   vBuffer = iTable:default-buffer-handle.
   create query vQuery.
   vQuery:add-buffer(vBuffer).
   if not vQuery:query-prepare("PRESELECT EACH " + vBuffer:name) 
   then do: 
      msg = substitute( "ERROR 1 ", error-status:get-message(1)).  
      putmes(msg).
      verror = yes.
   end.   
   if not vQuery:query-open()                              
   then do:
      msg = substitute( "ERROR 2 ", error-status:get-message(1)).  
      putmes(msg).
      verror = yes.
   end.   
   vQuery:get-first().
   if vBuffer:available
   then do:
      define variable vCheck as logical no-undo.
      vCheck = yes.
      if  vBuffer:name eq "{&prefixtt}TABLE"
      then 
         vBufferName = "_file".

      else if  vBuffer:name eq "{&prefixtt}field"
      then  do:
         assign
            vBufferName = "_field"
            vCheckField = yes
         .
         
      end.   
      else if  vBuffer:name eq "{&prefixtt}Index"
      then 
         vBufferName = "_Index".
      else if  vBuffer:name eq "{&prefixtt}Sequence"
      then 
         vBufferName = "_Sequence".
      else
         return no.   
     
         
      create buffer vBufferDB for table  vBufferName no-error.
      vFieldPref = length("{&prefixfil}") + 1.
      block-tt: 
      do while vBuffer:available:
         if vBuffer::{&prefixfil}mode eq "rename"  /* Пока  пропустим */
        then do:
           vQuery:get-next().
           next block-tt.
        end.
      if  vBuffer:name eq "{&prefixtt}TABLE"
      then do:
         find first buf{&prefixtt}TABLE where buf{&prefixtt}TABLE.{&prefixfil}name eq  vBuffer::{&prefixfil}name
                                          and buf{&prefixtt}TABLE.{&prefixfil}localIndex > vBuffer::{&prefixfil}localIndex
         no-error.
         if available buf{&prefixtt}TABLE
         then
            vCheck = no.
         vWhere      = substitute ("where _file._file-name eq &1 ",if vBuffer::{&prefixfil}mode eq "rename" then vBuffer::{&prefixfil}NewName else  vBuffer::{&prefixfil}name).
      
      end.
      else if  vBuffer:name eq "{&prefixtt}field"
      then do:
         define variable vvvv as character no-undo.
         vFieldValue = trim(  vBuffer::{&prefixfil}table, '"').
         find first _file no-lock where _file._file-name = vFieldValue  no-error.
         if available _file
         then do:
            vWhere      = substitute ("where _field._file-recid eq &1 and _field._Field-Name eq &2 ",recid(_file),if vBuffer::{&prefixfil}mode eq "rename" then vBuffer::{&prefixfil}NewName else  vBuffer::{&prefixfil}name).
            if     vFieldValue = "db"
               and trim(vBuffer::{&prefixfil}name,'"') eq "reserve1-char"
            then
               vCheck = no. 
         end.   
      end.   
      else if  vBuffer:name eq "{&prefixtt}Index"
      then do:
         vFieldValue =  trim( vBuffer::{&prefixfil}table, '"').
         find first _file no-lock where _file._file-name = vFieldValue no-error.
         if available _file
         then 
            vWhere      = substitute ("where _Index._file-recid eq &1 and _Index._Index-Name eq &2 ",recid(_file),if vBuffer::{&prefixfil}mode eq "rename" then vBuffer::{&prefixfil}NewName else  vBuffer::{&prefixfil}name).
      end.
      else if  vBuffer:name eq "{&prefixtt}Sequence"
      then 
         vWhere      = substitute ("where _Sequence._Seq-Name eq &1 ",vBuffer::{&prefixfil}name).
      else
         return no.
         vBufferDB:find-last(vWhere, no-lock) no-error.
         vOk = no.
         if vBufferDB:available
            and vBuffer::{&prefixfil}mode ne "drop"
            and vCheck          
         then do:
            vOk = yes.
            if vCheckField then         
            block-field:
            do vItm = 1 to vBuffer:num-fields:
               define variable vValuelog as logical no-undo.   
               vValuelog = yes.
               vField = vBuffer:buffer-field(vItm).
               vFieldName = "_" + substring(vField:name,vFieldPref).
               if vFieldName eq "_DESCRIPTION"
               then
                  vFieldName = "_DESC".
               else if vFieldName eq "_POSITION"
               then
                  vFieldName = "_field-rpos".
               else if vFieldName eq "_MAX-WIDTH"
               then
                  vFieldName = "_WIDTH".
               else if vFieldName eq "_COLUMN-LABEL"
               then
                  vFieldName = "_Col-label".
               else if vFieldName eq "_COLUMN-LABEL-SA"
               then
                  vFieldName = "_Label-SA".
               else if vFieldName eq "_CASE-SENSITIVE"
               then
                  vFieldName = "_fld-case".
               else if vFieldName eq "_NOT-CASE-SENSITIVE"
               then
                  assign
                    vValuelog  = no
                    vFieldName = "_fld-case"
                  .
               else if vFieldName eq "_NULL-ALLOWED"
               then
                  assign
                     vValuelog  = no
                     vFieldName = "_MANDATORY"
                  .
               
               
               if     (not can-do("_mode,_name,_table,_localindex,_NewName",vFieldName)
                  and vField:buffer-value ne "")
               then do vj = 1 to if vField:buffer-value eq ? then 1 else num-entries(vField:buffer-value,{&delim-par}):
                  define variable vValuedb as character no-undo.
                  vFieldValue = replace(trim(vField:buffer-value," "),'"','').
                  vValuedb = replace(vBufferDB:buffer-field(vFieldName):buffer-value,'"','').
                  vFlagEQ = if vFieldValue eq "{&logicalfield}" 
                        then 
                           logical (vValuedb) eq vValuelog
                        else
                           vValuedb eq vFieldValue.
                   if vFlagEQ
                   then
                      vField:buffer-value = "".
                   else 
                      vOk = no.           
               end.    
            end.
             
         end.
         else if    ( not vBufferDB:available
                 and vBuffer::{&prefixfil}mode eq "drop")
                 or not vCheck
         then          
            vOk = yes.
           
         if vOk
         then
            vBuffer:buffer-delete ().
         else do:
            oOkl = no.
           /* message "!!!!!!"
               view-as alert-box.*/
         end.    
         
         vQuery:get-next().
         
      end.
   end.
   ookl = not verror and oOkl.
   vQuery:query-close().

   delete object vQuery.
 /*  output stream Ostream close.*/
   finally:
      return oOkl.
   end finally.   
end method.

/*------------------------------------------------------------------------
  Method      : DeleteFieldsForHeadTable
  Parameters  : iTableName    - имя таблицы, у которой удаляем лишние поля и индексы
  Purpose     : Удаление всех индексов кроме pi и 
                полей в таблице не из индекса pi 
  Author(s)   : Ростовцев Александр
  Created     : 18.04.2025
  Notes       : Метод удаляет все индексы кроме pi и 
                удаляет поля из таблицы не из индекса pi  
                для головной таблице истории
  ----------------------------------------------------------------------*/
method private void DeleteFieldsForHeadTable(iTableName as character):
   
   define variable vIndex as character no-undo.
   define variable vField as character no-undo.

   for each {&prefixtt}Index where 
             {&prefixtt}Index.{&prefixfil}table = iTableName
         and {&prefixtt}Index.{&prefixfil}Name  <> "~"pi~"":  
     delete {&prefixtt}Index.  
   end.
   for first {&prefixtt}Index where 
             {&prefixtt}Index.{&prefixfil}table = iTableName
         and {&prefixtt}Index.{&prefixfil}Name  = "~"pi~"":  
     vIndex = replace({&prefixtt}Index.{&prefixfil}INDEX-FIELD,{&delim-par},",").
     for each {&prefixtt}FIELD where 
              {&prefixtt}FIELD.{&prefixfil}table = iTableName:
       vField = substitute("&1 ASCENDING",{&prefixtt}FIELD.{&prefixfil}Name).
       if not can-do(vIndex, vField) then
       do:
         vField = substitute("&1 DESCENDING",{&prefixtt}FIELD.{&prefixfil}Name).
         if not can-do(vIndex, vField) then
           delete {&prefixtt}FIELD.
       end.
     end.
   end.
end method.

method private void ChangeTable(OldName as character, NewName as character ):
   for each {&prefixtt}FIELD where {&prefixtt}FIELD.{&prefixfil}table eq oldName:
      {&prefixtt}FIELD.{&prefixfil}table = newName.
   end.
   for each {&prefixtt}Index where {&prefixtt}Index.{&prefixfil}table eq oldName:
      {&prefixtt}Index.{&prefixfil}table = newName.
   end. 
end method.

method private void ChangeAreahist(iTableName as character ):
   
   for each {&prefixtt}Index where {&prefixtt}Index.{&prefixfil}table eq iTableName :
      {&prefixtt}Index.{&prefixfil}area = '"History_Index"'.
   end. 
end method.

method private void addIndexHeadHist(iTableName as character ):
   define buffer buf_{&prefixtt}Index for {&prefixtt}Index.

   for each {&prefixtt}Index where {&prefixtt}Index.{&prefixfil}localIndex ne 0  :
   /* По идее здесь должен быть pi */
      create buf_{&prefixtt}Index.
      buffer-copy {&prefixtt}Index except {&prefixfil}PRIMARY {&prefixfil}UNIQUE {&prefixfil}localIndex  {&prefixfil}Name to buf_{&prefixtt}Index
      assign
        buf_{&prefixtt}Index.{&prefixfil}Name = '"sub"'
      .
      assign 
         buf_{&prefixtt}Index.{&prefixfil}INDEX-FIELD = '"subject" ASCENDING'
                                                      + {&delim-par} + buf_{&prefixtt}Index.{&prefixfil}INDEX-FIELD 
                                                      + {&delim-par} + '"corr-date" ASCENDING'
                                                      + {&delim-par} + '"corr-time" ASCENDING'
                                                      + {&delim-par} + '"corr-user-db-num" ASCENDING'
                                                     
             {&prefixtt}Index.{&prefixfil}INDEX-FIELD =     {&prefixtt}Index.{&prefixfil}INDEX-FIELD 
                                                      + {&delim-par} + '"corr-user-db-num" ASCENDING'
                                                      + {&delim-par} + '"chip-num" ASCENDING'
                                                      + {&delim-par} + '"subject" ASCENDING'
      .
   end.
   create {&prefixtt}Index.
   assign
      {&prefixtt}Index.{&prefixfil}mode        = "ADD"
      {&prefixtt}Index.{&prefixfil}Table       = iTableName
      {&prefixtt}Index.{&prefixfil}Name        = '"chip-num"'
      {&prefixtt}Index.{&prefixfil}AREA        = '"History_Index"'
      {&prefixtt}Index.{&prefixfil}INDEX-FIELD = '"chip-num" ASCENDING'
   .

   create {&prefixtt}Index.
   assign
      {&prefixtt}Index.{&prefixfil}mode        = "ADD"
      {&prefixtt}Index.{&prefixfil}Table       = iTableName
      {&prefixtt}Index.{&prefixfil}Name        = '"corr-user-db-num"'
      {&prefixtt}Index.{&prefixfil}AREA        = '"History_Index"'
      {&prefixtt}Index.{&prefixfil}INDEX-FIELD = '"corr-user-db-num" ASCENDING'
   .
   
   create {&prefixtt}Index.
   assign
      {&prefixtt}Index.{&prefixfil}mode        = "ADD"
      {&prefixtt}Index.{&prefixfil}Table       = iTableName
      {&prefixtt}Index.{&prefixfil}Name        = '"user-name"'
      {&prefixtt}Index.{&prefixfil}AREA        = '"History_Index"'
      {&prefixtt}Index.{&prefixfil}INDEX-FIELD = '"corr-user-name" ASCENDING' + {&delim-par} + '"corr-user-db-num" ASCENDING'
   .
end method.

method private void addIndexAttr(iTableName as character ):
   define buffer buf_{&prefixtt}Index for {&prefixtt}Index.
   define variable vArea as character no-undo.
   
   for first {&prefixtt}Index where 
             {&prefixtt}Index.{&prefixfil}table = iTableName
         and {&prefixtt}Index.{&prefixfil}Name  = "~"pi~"":  
     {&prefixtt}Index.{&prefixfil}INDEX-FIELD = 
       substitute("&1&2~"attr-code~" ASCENDING",{&prefixtt}Index.{&prefixfil}INDEX-FIELD,{&delim-par}).
     vArea = {&prefixtt}Index.{&prefixfil}AREA.
   end.

   create {&prefixtt}Index.
   assign
      {&prefixtt}Index.{&prefixfil}mode        = "ADD"
      {&prefixtt}Index.{&prefixfil}Table       = iTableName
      {&prefixtt}Index.{&prefixfil}Name        = '"code-value"'
      {&prefixtt}Index.{&prefixfil}AREA        = vArea
      {&prefixtt}Index.{&prefixfil}INDEX-FIELD = '"attr-code" ASCENDING' + {&delim-par} + '"attr-value" ASCENDING'
   .

end method.

method private void addindexHist(iTableName as character ):
   define buffer buf_{&prefixtt}Index for {&prefixtt}Index.
   
   for each {&prefixtt}Index where {&prefixtt}Index.{&prefixfil}localIndex ne 0  :
      create buf_{&prefixtt}Index.
      buffer-copy {&prefixtt}Index except {&prefixfil}PRIMARY {&prefixfil}UNIQUE {&prefixfil}localIndex  {&prefixfil}Name to buf_{&prefixtt}Index
      assign
      buf_{&prefixtt}Index.{&prefixfil}Name = '"' + trim({&prefixtt}Index.{&prefixfil}Name,'"') + '-2"'
      .
      assign 
         buf_{&prefixtt}Index.{&prefixfil}INDEX-FIELD = buf_{&prefixtt}Index.{&prefixfil}INDEX-FIELD 
                                                      + {&delim-par} + '"corr-date" ASCENDING'
                                                      + {&delim-par} + '"corr-time" ASCENDING'
                                                      + {&delim-par} + '"corr-user-db-num" ASCENDING'
                                                     
             {&prefixtt}Index.{&prefixfil}INDEX-FIELD =     {&prefixtt}Index.{&prefixfil}INDEX-FIELD 
                                                      + {&delim-par} + '"corr-user-db-num" ASCENDING'
                                                      + {&delim-par} + '"chip-num" ASCENDING'
      .
      


      
   end.
   create {&prefixtt}Index.
   assign
      {&prefixtt}Index.{&prefixfil}mode        = "ADD"
      {&prefixtt}Index.{&prefixfil}Table       = iTableName
      {&prefixtt}Index.{&prefixfil}Name        = '"corr-user-db-num"'
      {&prefixtt}Index.{&prefixfil}AREA        = '"History_Index"'
      {&prefixtt}Index.{&prefixfil}INDEX-FIELD = '"corr-user-db-num" ASCENDING'
   .
   
   create {&prefixtt}Index.
   assign
      {&prefixtt}Index.{&prefixfil}mode        = "ADD"
      {&prefixtt}Index.{&prefixfil}Table       = iTableName
      {&prefixtt}Index.{&prefixfil}Name        = '"corr-user-name"'
      {&prefixtt}Index.{&prefixfil}AREA        = '"History_Index"'
      {&prefixtt}Index.{&prefixfil}INDEX-FIELD = '"corr-user-name" ASCENDING' + {&delim-par} + '"corr-user-db-num" ASCENDING'
   .
end method.

method private void addFieldAttr(iTableName as character ):
   define variable vORDER    as integer no-undo init 0.
   define variable vPOSITION as integer no-undo init 1. 
   for each {&prefixtt}FIELD where {&prefixtt}FIELD.{&prefixfil}table eq iTableName
       by int({&prefixtt}FIELD.{&prefixfil}ORDER):
      assign
        vPOSITION                              = vPOSITION + 1
       {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      .
   end.
   for each {&prefixtt}FIELD where {&prefixtt}FIELD.{&prefixfil}table eq iTableName
       by int({&prefixtt}FIELD.{&prefixfil}POSITION):
      assign
      vORDER                                  = vORDER + 10
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      .
   end.

   create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       ='"attr-code"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "character"
      {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"X(8)"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL    = '""'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"Код атрибута"'
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = "16"
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      {&prefixtt}FIELD.{&prefixfil}MANDATORY  = "{&logicalfield}"
   .

   create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       ='"attr-value"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "character"
      {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"X(20)"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL    = '""'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"Значение атрибута"'
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = "40"
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
   .

end method.

method private void addFieldHist(iTableName as character, iIsHead as logical ):
   define variable vORDER    as integer no-undo.
   define variable vPOSITION as integer no-undo. 
   for each {&prefixtt}FIELD where {&prefixtt}FIELD.{&prefixfil}table eq iTableName:
      assign
         vORDER    = max(vORDER   ,int({&prefixtt}FIELD.{&prefixfil}ORDER    ))
         vPOSITION = max(vPOSITION,int({&prefixtt}FIELD.{&prefixfil}POSITION ))
      .
   end.
   assign
      vORDER    = max(vORDER,1000)
      vPOSITION = max(vPOSITION,100)
   .
   /* ADD FIELD "chip-num" OF "c-PromoCriterion" AS integer*/
   create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       ='"chip-num"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "integer"
      {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"->,>>>,>>9"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL    = '"0"'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"Уникальный код"'
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = "4"
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      {&prefixtt}FIELD.{&prefixfil}MANDATORY  = "{&logicalfield}"
      
   .

   /*ADD FIELD "corr-date" OF "c-PromoCriterion" AS date */
   create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       = '"corr-date"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "date"
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"99/99/99"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL    = '?'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"Дата действия"'
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '4'
   .

   /* ADD FIELD "corr-time" OF "c-PromoCriterion" AS integer */
   create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       = '"corr-time"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "integer"
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"->,>>>,>>9"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL    = '"0"'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"Время действия"'
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '4'
   .
  
   /*ADD FIELD "corr-user-db-num" OF "c-PromoCriterion" AS integer */
   create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       = '"corr-user-db-num"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "integer"
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"->,>>>,>>9"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL    = '"0"'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"ДБ создания"'
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '4'
      {&prefixtt}FIELD.{&prefixfil}MANDATORY  = "{&logicalfield}"
   .

    /*ADD FIELD "corr-user-name" OF "c-PromoCriterion" AS character */
   create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       = '"corr-user-name"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "character"
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"x(8)"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL    = '""'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"Изменил"'
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '16'
  .
  
  /*ADD FIELD "action" OF "c-promo-schedule-week" AS integer*/ 
  create {&prefixtt}FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      {&prefixtt}FIELD.{&prefixfil}localIndex = 1
      {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
      {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
      {&prefixtt}FIELD.{&prefixfil}Name       = '"action"'
      {&prefixtt}FIELD.{&prefixfil}Data-Type  = "integer"
      {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
      {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER)
      {&prefixtt}FIELD.{&prefixfil}DESCRIPTION =  '"Описание действия"'
      {&prefixtt}FIELD.{&prefixfil}FORMAT      = '"99"'
      {&prefixtt}FIELD.{&prefixfil}INITIAL     = '"0"'
      {&prefixtt}FIELD.{&prefixfil}LABEL       = '"Описание действия"'
      {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH   = '4'
   .

   if iIsHead then
   do:
    /*ADD FIELD "subject" OF "<iTableName>" AS CHARACTER*/
       create {&prefixtt}FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          {&prefixtt}FIELD.{&prefixfil}localIndex = 1
          {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
          {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
          {&prefixtt}FIELD.{&prefixfil}Name       = '"subject"'
          {&prefixtt}FIELD.{&prefixfil}Data-Type  = "character"
          {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
          {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER) 
          {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"X(8)"'
          {&prefixtt}FIELD.{&prefixfil}INITIAL    = '""'
          {&prefixtt}FIELD.{&prefixfil}LABEL      = '"Предмет изменения"'
          {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '16'
          {&prefixtt}FIELD.{&prefixfil}MANDATORY  = "логическое_поле"
       .

    /*ADD FIELD "is-news" OF "<iTableName>" AS logical*/
       create {&prefixtt}FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          {&prefixtt}FIELD.{&prefixfil}localIndex = 1
          {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
          {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
          {&prefixtt}FIELD.{&prefixfil}Name       = '"is-news"'
          {&prefixtt}FIELD.{&prefixfil}Data-Type  = "logical"
          {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
          {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER) 
          {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"yes/no"'
          {&prefixtt}FIELD.{&prefixfil}INITIAL    = '"no"'
          {&prefixtt}FIELD.{&prefixfil}LABEL      = '"Прием по новостям"'
          {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '1'
       .
       
    /*ADD FIELD "source-type" OF "<iTableName>" AS character*/
       create {&prefixtt}FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          {&prefixtt}FIELD.{&prefixfil}localIndex = 1
          {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
          {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
          {&prefixtt}FIELD.{&prefixfil}Name       = '"source-type"'
          {&prefixtt}FIELD.{&prefixfil}Data-Type  = "character"
          {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
          {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER) 
          {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"X(8)"'
          {&prefixtt}FIELD.{&prefixfil}INITIAL    = '""'
          {&prefixtt}FIELD.{&prefixfil}LABEL      = '"Источник изменения"'
          {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '16'
       .
    /*ADD FIELD "source-reа" OF "<iTableName>" AS character*/
       create {&prefixtt}FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          {&prefixtt}FIELD.{&prefixfil}localIndex = 1
          {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
          {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
          {&prefixtt}FIELD.{&prefixfil}Name       = '"source-ref"'
          {&prefixtt}FIELD.{&prefixfil}Data-Type  = "character"
          {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
          {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER) 
          {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"X(8)"'
          {&prefixtt}FIELD.{&prefixfil}INITIAL    = '""'
          {&prefixtt}FIELD.{&prefixfil}LABEL      = '"Ссылка на источник"'
          {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '16'
       .
   end.    
   else do:
    /*ADD FIELD "is-del" OF "c-promo-schedule-week" AS logical*/
       create {&prefixtt}FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          {&prefixtt}FIELD.{&prefixfil}localIndex = 1
          {&prefixtt}FIELD.{&prefixfil}mode       = "ADD"
          {&prefixtt}FIELD.{&prefixfil}Table      = iTableName
          {&prefixtt}FIELD.{&prefixfil}Name       = '"is-del"'
          {&prefixtt}FIELD.{&prefixfil}Data-Type  = "logical"
          {&prefixtt}FIELD.{&prefixfil}POSITION   = string(vPOSITION)
          {&prefixtt}FIELD.{&prefixfil}ORDER      = string (vORDER) 
          {&prefixtt}FIELD.{&prefixfil}FORMAT     = '"yes/no"'
          {&prefixtt}FIELD.{&prefixfil}INITIAL    = '"no"'
          {&prefixtt}FIELD.{&prefixfil}LABEL      = '""'
          {&prefixtt}FIELD.{&prefixfil}MAX-WIDTH  = '16'
       .
   end.
      
end method.

method public void crTriggerFile(
  iTableName as character,
  iFileName as character, 
  iTrigger as character ):
  define variable vFullName as character no-undo.
  
  vFullName = substitute("&1&2&3.p",session:temp-directory, iFileName, lc(substr(iTrigger,1,1))).
  output stream sTrigger to value(vFullName).
  put stream sTrigger unformatted
     "block-level on error undo, throw." skip(1)
     "/*" skip
     "$Revision$" skip
     "$Author$" skip
     "$Date$" skip
     "$Workfile$" skip
     "$Archive$" skip(1)
     "Автор: Сгенерировано автоматически методом " program-name(1) skip
     "Дата создания: " string(today,"99/99/9999") skip
     "Author: automatically generated by " program-name(1) skip
     "Created: " string(today,"99/99/9999") skip
     "*/" skip(1)
     "&glob main-tbl " iTableName skip
     "trigger procedure for " lc(iTrigger) " of ub.~{&main-tbl~}" 
  .
  if iTrigger = "write" then
  do:
    put stream sTrigger unformatted
      " " skip
      "  new buffer new-~{&main-tbl~}" skip
      "  old buffer old-~{&main-tbl~}" skip
    .
  end.
  put stream sTrigger unformatted 
    "." skip(1)
    "define variable vss-revision    as character no-undo initial ~"$Revision$~":U." skip
    "define variable vss-author      as character no-undo initial ~"$Author$~":U." skip
    "define variable vss-date        as character no-undo initial ~"$Date$~":U." skip
    "define variable vss-workfile    as character no-undo initial ~"$Workfile$~":U." skip
    "define variable vss-archive     as character no-undo initial ~"$Archive$~":U." skip
    "define variable vss-description as character no-undo init ~"Триггер на " lc(iTrigger) " " iTableName "~"." skip 
  . 
    
  output stream sTrigger close.
end method.

method public void crtablehist(iTableName as character ):
  crtablehist(iTableName, no, "").
end method.

method public void crtablehist(
   iTableName as character, 
   iCrSeq as logical, 
   iFileTrigger  as character 
):

   if not can-find(first {&prefixtt}TABLE where {&prefixtt}TABLE.{&prefixfil}Name = '"' + iTableName + '"') then
   do:
     /* if нужен для генерации таблицы истории по таблице атрибутов из crTableAttr */
     empty temp-table {&prefixtt}TABLE.
     empty temp-table {&prefixtt}FIELD.
     empty temp-table {&prefixtt}Index.
     empty temp-table {&prefixtt}SEQUENCE.
     run prodict/dump_df.p   (iTableName,
                              iTableName + ".df",
                              "").
     readDF(iTableName + ".df").
   end.

   define variable vnewName   as character no-undo.
   define variable vnewNameno as character no-undo.
   for each {&prefixtt}TABLE where not ( {&prefixtt}TABLE.{&prefixfil}Name begins "c-") :
      vnewNameno = "c-" + trim({&prefixtt}TABLE.{&prefixfil}Name,'"').
      vnewName = '"' + vnewNameno + '"'.
      ChangeTable({&prefixtt}TABLE.{&prefixfil}Name,vnewName).
      {&prefixtt}TABLE.{&prefixfil}Area = '"History"'.
      ChangeAreahist (vnewName).
      if iFileTrigger <> "" then
      do:
        crTriggerFile (vnewNameno, iFileTrigger, "WRITE").
        crTriggerFile (vnewNameno, iFileTrigger, "DELETE").
        {&prefixtt}TABLE.{&prefixfil}TABLE-TRIGGER = substitute(
          "~"DELETE~" OVERRIDE PROCEDURE ~"trg/&1d.p~" CRC ~"?~"~
&2~"WRITE~" OVERRIDE PROCEDURE ~"trg/&1w.p~" CRC ~"?~"",
          iFileTrigger, {&delim-par}).  
      end.
      else
      do:
        {&prefixtt}TABLE.{&prefixfil}TABLE-TRIGGER = "". 
      end. 
      addFieldHist (vnewName, false).
      addIndexHist (vnewName).
      {&prefixtt}TABLE.{&prefixfil}Name     = vnewName.
      {&prefixtt}TABLE.{&prefixfil}DUMP-NAME = '"' + lc(vnewNameno) + '"'.
      if iCrSeq then
      do:
        create {&prefixtt}SEQUENCE.
        assign
          {&prefixtt}SEQUENCE.{&prefixfil}mode           = "ADD"
          {&prefixtt}SEQUENCE.{&prefixfil}Name           = "s-" + vnewNameno + "-chip-num"
          {&prefixtt}SEQUENCE.{&prefixfil}INITIAL        = '0'
          {&prefixtt}SEQUENCE.{&prefixfil}INCREMENT      = '1'
          {&prefixtt}SEQUENCE.{&prefixfil}CYCLE-ON-LIMIT = 'no'
        .
      end.
   end.
   dumpTable ("c-" + iTableName + ".df"). 
   if not noMessage then
     message "c-" + iTableName + ".df" search("c-" + iTableName + ".df")
     view-as alert-box. 
 end method.

/*------------------------------------------------------------------------
  Method      : crTableHeadHist
  Parameters  : iTableName    - имя таблицы, для которой генерируем новую таблицу
                iTableHead    - имя новой головной таблицы
                iSequenceName - имя последовательности (Sequence) для истории
                iFileTrigger  - имя файла триггера для новой таблицы без суффикса
                                (например: для "cordh" будет прописано "trg/cordhd.p" и 
                                "trg/cordhw.p")
  Purpose     : Генерация головной таблицы для истории 
  Author(s)   : Ростовцев Александр
  Created     : 18.04.2025
  Notes       : Метод генерирует df-файл головной таблицы истории
  ----------------------------------------------------------------------*/
method public void crTableHeadHist
   ( iTableName    as character
   , iTableHead    as character
   , iSequenceName as character
   , iFileTrigger  as character):
   
   empty temp-table {&prefixtt}TABLE.
   empty temp-table {&prefixtt}FIELD.
   empty temp-table {&prefixtt}Index.
   empty temp-table {&prefixtt}SEQUENCE.
   run prodict/dump_df.p   (iTableName,
                            iTableName + ".df",
                            "").
   readDF(iTableName + ".df").
   define variable vnewName   as character no-undo.
   define variable vnewNameno as character no-undo.
   for each {&prefixtt}TABLE where not ( {&prefixtt}TABLE.{&prefixfil}Name begins "c-") :
/*      run gbl/inidebug.p.*/
      vnewNameno = trim(iTableHead).
      vnewName = '"' + vnewNameno + '"'.
      DeleteFieldsForHeadTable({&prefixtt}TABLE.{&prefixfil}Name).
      ChangeTable({&prefixtt}TABLE.{&prefixfil}Name,vnewName).
      {&prefixtt}TABLE.{&prefixfil}Area = '"History"'.
      ChangeAreahist (vnewName).
      if iFileTrigger <> "" then
      do:
        crTriggerFile (vnewNameno, iFileTrigger, "WRITE").
        crTriggerFile (vnewNameno, iFileTrigger, "DELETE").
        {&prefixtt}TABLE.{&prefixfil}TABLE-TRIGGER = substitute(
          "~"DELETE~" OVERRIDE PROCEDURE ~"trg/&1d.p~" CRC ~"?~"~
&2~"WRITE~" OVERRIDE PROCEDURE ~"trg/&1w.p~" CRC ~"?~"",
          iFileTrigger, {&delim-par}).  
      end.
      else
      do:
        {&prefixtt}TABLE.{&prefixfil}TABLE-TRIGGER = "". 
      end. 
      addFieldHist (vnewName, true).
      addIndexHeadHist (vnewName).
      {&prefixtt}TABLE.{&prefixfil}Name     = vnewName.
      {&prefixtt}TABLE.{&prefixfil}DUMP-NAME = '"' + lc(vnewNameno) + '"'.
      create {&prefixtt}SEQUENCE.
      assign
         {&prefixtt}SEQUENCE.{&prefixfil}mode           = "add"
         {&prefixtt}SEQUENCE.{&prefixfil}Name           = trim(iSequenceName)
         {&prefixtt}SEQUENCE.{&prefixfil}INITIAL        = '0'
         {&prefixtt}SEQUENCE.{&prefixfil}INCREMENT      = '1'
         {&prefixtt}SEQUENCE.{&prefixfil}CYCLE-ON-LIMIT = 'no'
      .
      
   end.   
   dumpTable (iTableHead + ".df") no-error.
   
   if not noMessage then
     message iTableHead + ".df" search(iTableHead + ".df")
     view-as alert-box. 
end method.
 
/*------------------------------------------------------------------------
  Method      : crTableAttr
  Parameters  : iTableName    - имя таблицы, для которой генерируем таблицу атрибутов
  Purpose     : Генерация таблицы атрибутов 
  Author(s)   : Ростовцев Александр
  Created     : 06.05.2025
  ----------------------------------------------------------------------*/
method public void crTableAttr (
   iTableName       as character,
   iFileTrigger     as character,
   iCrHistAttr      as logical,
   iFileTriggerHist as character):
   
   define variable vnewName   as character no-undo.
   define variable vnewNameno as character no-undo.
   
   empty temp-table {&prefixtt}TABLE.
   empty temp-table {&prefixtt}FIELD.
   empty temp-table {&prefixtt}Index.
   empty temp-table {&prefixtt}SEQUENCE.
   run prodict/dump_df.p   (iTableName,
                            iTableName + ".df",
                            "").
   readDF(iTableName + ".df").

   for each {&prefixtt}TABLE where not ( {&prefixtt}TABLE.{&prefixfil}Name begins "c-") :
      vnewNameno = trim(iTableName) + "-attr".
      vnewName = '"' + vnewNameno + '"'.
      DeleteFieldsForHeadTable({&prefixtt}TABLE.{&prefixfil}Name).
      ChangeTable({&prefixtt}TABLE.{&prefixfil}Name,vnewName).
      if iFileTrigger <> "" then
      do:
        crTriggerFile (vnewNameno, iFileTrigger, "WRITE").
        crTriggerFile (vnewNameno, iFileTrigger, "DELETE").
        {&prefixtt}TABLE.{&prefixfil}TABLE-TRIGGER = substitute(
          "~"DELETE~" OVERRIDE PROCEDURE ~"trg/&1d.p~" CRC ~"?~"~
&2~"WRITE~" OVERRIDE PROCEDURE ~"trg/&1w.p~" CRC ~"?~"",
          iFileTrigger, {&delim-par}).  
      end.
      else
      do:
        {&prefixtt}TABLE.{&prefixfil}TABLE-TRIGGER = "". 
      end. 
      addFieldAttr (vnewName).
      addIndexAttr (vnewName).
      {&prefixtt}TABLE.{&prefixfil}Name     = vnewName.
      {&prefixtt}TABLE.{&prefixfil}DUMP-NAME = '"' + lc(vnewNameno) + '"'.
   end.
   dumpTable (iTableName + "-attr.df").
   if iCrHistAttr then
   do: 
     crtablehist(iTableName + "-attr", no, iFileTriggerHist).
   end.
   if not noMessage then
     message iTableName + "-attr.df" search(iTableName + "-attr.df")
     view-as alert-box. 
end method.

 method public void putmes (input itext as char):
    if not silent 
    then do:
       message itext
       view-as alert-box.
    end.
     
 end method.
 
   method public void putstat (input itext as char):
      if valid-handle(PublisHandle)
     then
        publish "putstat" from PublisHandle (itext ).
   end.
end class.