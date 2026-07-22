using Progress.Lang.*.
using ibs.th.adm.upd.*.
block-level on error undo, throw.
class ibs.th.adm.upd.analisdf final:
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
   constructor public analisdf (  ):
      obsrvdbObj = new observupd ().
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
  define variable mBuffer     as handle    no-undo.
  define variable mBufferName as character no-undo.
  define variable mName       as character no-undo.
        define temp-table tt-TABLE
     field f-mode as char
     field f-Name as char
     field f-NewName as char
     field f-AREA as char
     field f-LABEL as char
     field f-CAN-CREATE as char
     field f-CAN-DELETE as char
     field f-CAN-READ as char
     field f-CAN-WRITE as char
     field f-CAN-DUMP as char
     field f-CAN-LOAD as char
     field f-DESCRIPTION as char
     field f-DUMP-NAME as char
     field f-TABLE-TRIGGER as char
     field f-localIndex as integer
     index f-localIndex f-localIndex
 .
   define temp-table tt-FIELD
      field f-mode as char
      field f-Name as char
      field f-NewName as char
      field f-Table as char
      field f-Data-Type  as char
      field f-DESCRIPTION as char
      field f-FORMAT as char
      field f-INITIAL as char
      field f-INITIAL-SA as char
      field f-POSITION as char
      field f-MAX-WIDTH as char
      field f-DECIMALS as char
      field f-HELP as char
      field f-ORDER as char
      field f-MANDATORY as char
      field f-NULL-ALLOWED as char
      field f-CASE-SENSITIVE as char
      field f-NOT-CASE-SENSITIVE as char
      field f-VIEW-AS as char
      field f-FORMAT-SA as char
      field f-HELP-SA as char
      field f-LABEL as char
      field f-LABEL-SA as char
      field f-COLUMN-LABEL as char
      field f-COLUMN-LABEL-SA as char
      field f-CAN-READ as char
      field f-CAN-WRITE as char
      field f-VALEXP as char
      field f-VALMSG as char
      field f-VALMSG-SA as char
      field f-EXTENT as char
      field f-localIndex as integer
     index f-localIndex f-localIndex
   .
define temp-table tt-INDEX
      field f-mode as char
      field f-Name as char
      field f-NewName as char
      field f-Table as char
      field f-AREA as char
      field f-DESCRIPTION as char
      field f-UNIQUE as char
      field f-PRIMARY as char
      field f-INDEX-FIELD as char
      field f-Word as char
      field f-localIndex as integer
      field f-inactive as Char
     index f-localIndex f-localIndex
   .
   define temp-table tt-SEQUENCE
      field f-mode as char
      field f-Name as char
      field f-NewName as char
      field f-INITIAL as char
      field f-INCREMENT as char
      field f-CYCLE-ON-LIMIT as char
      field f-MIN-VAL as char
      field f-MAX-VAL as char
      field f-localIndex as integer
     index f-localIndex f-localIndex
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
     for each tt-FIELD where f-Name       = '"reserve1-char"'
                                 and f-Table      = '"db"'
     :
        f-initial    = '"' + string(vi) + '"' .
        VavailVer = yes.
     end.
     if not VavailVer
     then do:
        create tt-FIELD.
        assign
          f-mode       = "UPDATE"
          f-Name       = '"reserve1-char"'
          f-Table      = '"db"'
          f-initial    = '"' + string(vi) + '"'
          f-localIndex = 1
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
         create buffer mBuffer for table "tt-" + mBufferName no-error.
         if error-status:error
         then do:
            msg = substitute( "Не известный буфер &1" , "tt-" + mBufferName).
            putmes(msg).
            return yes.
         end.
         mName = entry(3 + vSdvig,istr, " ") no-error.
         if error-status:error
         then do:
            msg = substitute( "Ошибка структуре df файла не задан объект для метода &1  для таблицы &2" ,vMode , "tt-" + mBufferName).
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
               vOptionalWhere = substitute (" and tt-&1.f-table eq '&2'",mBufferName,vTableWhere).
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
               vOptionalWhere = substitute (" and tt-&1.f-table eq '&2'",mBufferName,vTableWhere).
            end.
         end.
         else
            vOptionalWhere = "".
         vOptionalWhere = substitute ("where tt-&1.f-Name eq '&2' &3",mBufferName,mName,vOptionalWhere).
         mBuffer:find-last(vOptionalWhere, no-lock) no-error.
         if mBuffer:available
         then do:
            if     vMode                     eq "rename"
               and mBuffer::f-mode eq "add"
            then do:
               if mbuffername eq "table"
               then do:
                  ChangeTable(mBuffer::f-Name , entry(5,istr, " ")).
                  mBuffer::f-Name = entry(5,istr, " ").
               end.
               else
                  mBuffer::f-Name = vtarget.
                  return no.
            end.
            else if      mBuffer::f-mode eq "rename"
                      or (    vMode eq "rename"
                          and vmode eq "update")
            then do:
               mposih = mBuffer::f-localIndex + 1.
               mBuffer:buffer-release ().
            end.
            else if vmode eq "add"
            then do:
               if mBuffer::f-mode eq "drop"
               then do:
                  mposih = mBuffer::f-localIndex + 1.
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
               if mBuffer::f-mode eq "add" or mBuffer::f-mode eq "update"
               then do:
                  if mbuffername eq "table"
                  then do:
                     for each tt-FIELD where tt-FIELD.f-Table eq mBuffer::f-name:
                        delete tt-FIELD.
                     end.
                     for each tt-index where tt-index.f-Table eq mBuffer::f-name:
                        delete tt-index.
                     end.
                  end.
                  if mBuffer::f-mode eq "add"
                  then do:
                     mBuffer:buffer-delete ().
                     return no.
                  end.
                  else
                     mBuffer:buffer-delete ().
               end.
               else
                  mBuffer::f-mode = vmode.
            end.
         end.
         if not mBuffer:available
         then do:
            mBuffer:buffer-create ().
            mBuffer::f-mode       = vmode.
            mBuffer::f-Name       = mName.
            mBuffer::f-localIndex = mposih.
            if vMode eq "rename"
            then
               mBuffer::f-NewName = if    mbuffername eq "table"
                                                 or mbuffername eq "index"
                                              then entry(5,istr, " ")
                                              else entry(7,istr, " ").
         end.
         if VPrimary
         then
           mBuffer:buffer-field("f-PRIMARY"):BUFFER-VALUE () = "логическое_поле".
         if    mBufferName eq "field"
            or mBufferName eq "index"
         then
            mBuffer::f-table = vTableWhere.
         if    mBufferName eq "field"
            and vMode ne "rename"
         then do:
            mBuffer::f-Data-Type = entry(7,istr, " ") no-error.
            if     error-status:error
               and vMode eq "add"
            then do:
               msg = substitute( "Ошибка структуре df файла не задан таблица для &1 &2", mBufferName, mName).
               putmes(msg).
               return yes.
            end.
         end.
      end.
      else do:
         if    mBufferName eq "table" and can-do("AREA,LABEL,DESCRIPTION,DUMP-NAME,TABLE-TRIGGER,CAN-CREATE,CAN-DELETE,CAN-READ,CAN-WRITE,CAN-DUMP,CAN-LOAD",trim(vMode,'"'))
            or mBufferName eq "field" and can-do("DESCRIPTION,FORMAT,INITIAL,LABEL,POSITION,MAX-WIDTH,COLUMN-LABEL,DECIMALS,HELP,ORDER,MANDATORY,NULL-ALLOWED,CASE-SENSITIVE,NOT-CASE-SENSITIVE,VIEW-AS,FORMAT-SA,HELP-SA,LABEL-SA,COLUMN-LABEL-SA,CAN-READ,CAN-WRITE,VALEXP,VALMSG,VALMSG-SA,EXTENT,INITIAL-SA",trim(vMode,'"'))
            or mBufferName eq "INDEX" and can-do("AREA,DESCRIPTION,UNIQUE,PRIMARY,INDEX-FIELD,WORD,inactive",trim(vMode,'"'))
            or mBufferName eq "SEQUENCE" and can-do("INITIAL,INCREMENT,CYCLE-ON-LIMIT,MIN-VAL,MAX-VAL",trim(vMode,'"'))
         then do:
               if     ActiveIndexAll
                  and mBufferName eq "INDEX" and can-do("inactive",trim(vMode,'"'))
               then
                  return no.
               vFieldName = "f-" + vMode no-error.
               if error-status:error
               then do:
                  msg = substitute( "Ошибка структуре df  объекта &1 &2 нет поля в таблице &3", mBufferName, mName, "f-" + vMode).
                  putmes(msg).
                  return yes.
               end.
               define variable vval as character no-undo.
               vval = trim(
                                                                  (if can-do("INDEX-FIELD,TABLE-TRIGGER" ,vmode)
                                                                  then mBuffer:buffer-field(vFieldName):BUFFER-VALUE () + chr(4)
                                                                  else "")
                                                                + trim (substring (istr,length(vMode) + 2))
                                                                ,chr(4) ).
               if trim(vMode,'"') = "DESCRIPTION" then
               do:
                 BLOCK_DESC:
                 repeat:
                   vFilePos = seek(sReadfile).
                   import stream sReadfile unformatted vStr.
                   vStr1 = entry(1, trim(vStr), " ").
                   if mBufferName eq "table" and can-do("AREA,LABEL,DESCRIPTION,DUMP-NAME,TABLE-TRIGGER,CAN-CREATE,CAN-DELETE,CAN-READ,CAN-WRITE,CAN-DUMP,CAN-LOAD",trim(vStr1,'"'))
                      or mBufferName eq "field" and can-do("DESCRIPTION,FORMAT,INITIAL,LABEL,POSITION,MAX-WIDTH,COLUMN-LABEL,DECIMALS,HELP,ORDER,MANDATORY,NULL-ALLOWED,CASE-SENSITIVE,NOT-CASE-SENSITIVE,VIEW-AS,FORMAT-SA,HELP-SA,LABEL-SA,COLUMN-LABEL-SA,CAN-READ,CAN-WRITE,VALEXP,VALMSG,VALMSG-SA,EXTENT,INITIAL-SA",trim(vStr1,'"'))
                      or mBufferName eq "INDEX" and can-do("AREA,DESCRIPTION,UNIQUE,PRIMARY,INDEX-FIELD,WORD,inactive",trim(vStr1,'"')) then
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
                  mBuffer:buffer-field(vFieldName):BUFFER-VALUE () = "логическое_поле".
               if error-status:error
               then do:
                  msg = substitute( "2 Ошибка структуре df  объекта &1 &2", mBufferName, mName).
                  putmes(msg).
                  return yes.
               end.
               if vMode eq "NULL-ALLOWED"
               then
                  mBuffer:buffer-field("f-MANDATORY"):BUFFER-VALUE () = "".
               else if vMode eq "MANDATORY"
               then
                  mBuffer:buffer-field("f-NULL-ALLOWED"):BUFFER-VALUE () = "".
               else if vMode eq "NOT-CASE-SENSITIVE"
               then
                  mBuffer:buffer-field("f-CASE-SENSITIVE"):BUFFER-VALUE () = "".
               else if vMode eq "CASE-SENSITIVE"
               then
                  mBuffer:buffer-field("f-NOT-CASE-SENSITIVE"):BUFFER-VALUE () = "".
         end.
         else do:
            msg = substitute( "Ошибка структуре df  объекта &1 &2 неизвестное выражение &3",mBufferName, mName, vMode).
            putmes(msg).
            return yes.
         end.
      end.
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
      find first tt-Table no-error.
      if available tt-Table
      then
         dumpOneTable(ifile,buffer tt-Table:handle ).
      find first tt-field no-error.
      if available tt-field
      then
         dumpOneTable(ifile,buffer tt-field:handle ).
      find first tt-index no-error.
      if available tt-index
      then
         dumpOneTable(ifile,buffer tt-index:handle ).
      find first tt-SEQUENCE no-error.
      if available tt-SEQUENCE
      then
         dumpOneTable(ifile,buffer tt-SEQUENCE:handle ).
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
   vPredicate = "for EACH " + vBuffer:name + if vBuffer:name = "tt-FIELD" then " BY INT("  + vBuffer:name + ".f-ORDER)" else "".
   if not vQuery:query-prepare(vPredicate) then  do: msg = substitute( "ERROR 1 ", error-status:get-message(1)).  message msg view-as alert-box. end.
   if not vQuery:query-open()then  do: msg = substitute( "ERROR 2 ", error-status:get-message(1)).  message msg view-as alert-box. end.
   vQuery:get-first().
   if vBuffer:available
   then do:
      vFieldPref = length("f-") + 1.
      do while vBuffer:available:
         vtxt = if vBuffer:name eq "tt-field"
             then substitute ("&1 FIELD &2 OF &3 &4&5",
                              vBuffer::f-mode,
                              vBuffer::f-name,
                              vBuffer::f-table,
                              if vBuffer::f-mode eq "rename" then " TO " + vBuffer::f-NewName else "",
                              if vBuffer::f-Data-Type ne "" then "AS " + vBuffer::f-Data-Type else "")
             else if vBuffer:name eq "tt-index"
             then substitute ("&1 INDEX &2&3 ON &4",
                              vBuffer::f-mode,
                              vBuffer::f-name,
                              if vBuffer::f-mode eq "rename" then " TO " + vBuffer::f-NewName  else "",
                              if vBuffer::f-mode eq "rename" then vBuffer::f-table else vBuffer::f-table)
             else substitute ("&1 &2 &3&4",
                              vBuffer::f-mode,
                              substring(vBuffer:name,length("tt-") + 1),
                              vBuffer::f-name,
                              if vBuffer::f-mode eq "rename" then " TO " + vBuffer::f-NewName else ""
                              ).
         put stream Ostream unformatted vtxt skip.
         do vItm = 1 to vBuffer:num-fields:
            vField = vBuffer:buffer-field(vItm).
            vFieldName = substring(vField:name,vFieldPref).
            if not can-do("mode,name,newname,table,Data-Type,localindex" + (if DelArea then ",area" else "") ,vFieldName)
            then do:
               do vj = 1 to if vField:buffer-value eq ? then 1 else num-entries(vField:buffer-value,chr(4)):
                  define variable vValue as character no-undo.
                  vValue = entry(vj,vField:buffer-value,chr(4)).
                  if vValue eq "логическое_поле" then vValue = "".
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
      oOK = CheckOneTable(temp-table tt-Table:handle ).
      vOk = CheckOneTable(temp-table tt-field:handle ).
      oOK = oOK and vOk.
      vOk = CheckOneTable(temp-table tt-index:handle ).
      oOK = oOK and vOk.
      vOk = CheckOneTable(temp-table tt-SEQUENCE:handle ).
      oOK = oOK and vOk.
      if not oOK
      then
         dumpTable(ifile).
      return oOK.
   end.
method private logical CheckOneTable(iTable as  handle):
   define buffer buftt-TABLE for tt-TABLE.
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
      if  vBuffer:name eq "tt-TABLE"
      then
         vBufferName = "_file".
      else if  vBuffer:name eq "tt-field"
      then  do:
         assign
            vBufferName = "_field"
            vCheckField = yes
         .
      end.
      else if  vBuffer:name eq "tt-Index"
      then
         vBufferName = "_Index".
      else if  vBuffer:name eq "tt-Sequence"
      then
         vBufferName = "_Sequence".
      else
         return no.
      create buffer vBufferDB for table  vBufferName no-error.
      vFieldPref = length("f-") + 1.
      block-tt:
      do while vBuffer:available:
         if vBuffer::f-mode eq "rename"
        then do:
           vQuery:get-next().
           next block-tt.
        end.
      if  vBuffer:name eq "tt-TABLE"
      then do:
         find first buftt-TABLE where buftt-TABLE.f-name eq  vBuffer::f-name
                                          and buftt-TABLE.f-localIndex > vBuffer::f-localIndex
         no-error.
         if available buftt-TABLE
         then
            vCheck = no.
         vWhere      = substitute ("where _file._file-name eq &1 ",if vBuffer::f-mode eq "rename" then vBuffer::f-NewName else  vBuffer::f-name).
      end.
      else if  vBuffer:name eq "tt-field"
      then do:
         define variable vvvv as character no-undo.
         vFieldValue = trim(  vBuffer::f-table, '"').
         find first _file no-lock where _file._file-name = vFieldValue  no-error.
         if available _file
         then do:
            vWhere      = substitute ("where _field._file-recid eq &1 and _field._Field-Name eq &2 ",recid(_file),if vBuffer::f-mode eq "rename" then vBuffer::f-NewName else  vBuffer::f-name).
            if     vFieldValue = "db"
               and trim(vBuffer::f-name,'"') eq "reserve1-char"
            then
               vCheck = no.
         end.
      end.
      else if  vBuffer:name eq "tt-Index"
      then do:
         vFieldValue =  trim( vBuffer::f-table, '"').
         find first _file no-lock where _file._file-name = vFieldValue no-error.
         if available _file
         then
            vWhere      = substitute ("where _Index._file-recid eq &1 and _Index._Index-Name eq &2 ",recid(_file),if vBuffer::f-mode eq "rename" then vBuffer::f-NewName else  vBuffer::f-name).
      end.
      else if  vBuffer:name eq "tt-Sequence"
      then
         vWhere      = substitute ("where _Sequence._Seq-Name eq &1 ",vBuffer::f-name).
      else
         return no.
         vBufferDB:find-last(vWhere, no-lock) no-error.
         vOk = no.
         if vBufferDB:available
            and vBuffer::f-mode ne "drop"
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
               then do vj = 1 to if vField:buffer-value eq ? then 1 else num-entries(vField:buffer-value,chr(4)):
                  define variable vValuedb as character no-undo.
                  vFieldValue = replace(trim(vField:buffer-value," "),'"','').
                  vValuedb = replace(vBufferDB:buffer-field(vFieldName):buffer-value,'"','').
                  vFlagEQ = if vFieldValue eq "логическое_поле"
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
                 and vBuffer::f-mode eq "drop")
                 or not vCheck
         then
            vOk = yes.
         if vOk
         then
            vBuffer:buffer-delete ().
         else do:
            oOkl = no.
         end.
         vQuery:get-next().
      end.
   end.
   ookl = not verror and oOkl.
   vQuery:query-close().
   delete object vQuery.
   finally:
      return oOkl.
   end finally.
end method.
method private void DeleteFieldsForHeadTable(iTableName as character):
   define variable vIndex as character no-undo.
   define variable vField as character no-undo.
   for each tt-Index where
             tt-Index.f-table = iTableName
         and tt-Index.f-Name  <> "~"pi~"":
     delete tt-Index.
   end.
   for first tt-Index where
             tt-Index.f-table = iTableName
         and tt-Index.f-Name  = "~"pi~"":
     vIndex = replace(tt-Index.f-INDEX-FIELD,chr(4),",").
     for each tt-FIELD where
              tt-FIELD.f-table = iTableName:
       vField = substitute("&1 ASCENDING",tt-FIELD.f-Name).
       if not can-do(vIndex, vField) then
       do:
         vField = substitute("&1 DESCENDING",tt-FIELD.f-Name).
         if not can-do(vIndex, vField) then
           delete tt-FIELD.
       end.
     end.
   end.
end method.
method private void ChangeTable(OldName as character, NewName as character ):
   for each tt-FIELD where tt-FIELD.f-table eq oldName:
      tt-FIELD.f-table = newName.
   end.
   for each tt-Index where tt-Index.f-table eq oldName:
      tt-Index.f-table = newName.
   end.
end method.
method private void ChangeAreahist(iTableName as character ):
   for each tt-Index where tt-Index.f-table eq iTableName :
      tt-Index.f-area = '"History_Index"'.
   end.
end method.
method private void addIndexHeadHist(iTableName as character ):
   define buffer buf_tt-Index for tt-Index.
   for each tt-Index where tt-Index.f-localIndex ne 0  :
      create buf_tt-Index.
      buffer-copy tt-Index except f-PRIMARY f-UNIQUE f-localIndex  f-Name to buf_tt-Index
      assign
        buf_tt-Index.f-Name = '"sub"'
      .
      assign
         buf_tt-Index.f-INDEX-FIELD = '"subject" ASCENDING'
                                                      + chr(4) + buf_tt-Index.f-INDEX-FIELD
                                                      + chr(4) + '"corr-date" ASCENDING'
                                                      + chr(4) + '"corr-time" ASCENDING'
                                                      + chr(4) + '"corr-user-db-num" ASCENDING'
             tt-Index.f-INDEX-FIELD =     tt-Index.f-INDEX-FIELD
                                                      + chr(4) + '"corr-user-db-num" ASCENDING'
                                                      + chr(4) + '"chip-num" ASCENDING'
                                                      + chr(4) + '"subject" ASCENDING'
      .
   end.
   create tt-Index.
   assign
      tt-Index.f-mode        = "ADD"
      tt-Index.f-Table       = iTableName
      tt-Index.f-Name        = '"chip-num"'
      tt-Index.f-AREA        = '"History_Index"'
      tt-Index.f-INDEX-FIELD = '"chip-num" ASCENDING'
   .
   create tt-Index.
   assign
      tt-Index.f-mode        = "ADD"
      tt-Index.f-Table       = iTableName
      tt-Index.f-Name        = '"corr-user-db-num"'
      tt-Index.f-AREA        = '"History_Index"'
      tt-Index.f-INDEX-FIELD = '"corr-user-db-num" ASCENDING'
   .
   create tt-Index.
   assign
      tt-Index.f-mode        = "ADD"
      tt-Index.f-Table       = iTableName
      tt-Index.f-Name        = '"user-name"'
      tt-Index.f-AREA        = '"History_Index"'
      tt-Index.f-INDEX-FIELD = '"corr-user-name" ASCENDING' + chr(4) + '"corr-user-db-num" ASCENDING'
   .
end method.
method private void addIndexAttr(iTableName as character ):
   define buffer buf_tt-Index for tt-Index.
   define variable vArea as character no-undo.
   for first tt-Index where
             tt-Index.f-table = iTableName
         and tt-Index.f-Name  = "~"pi~"":
     tt-Index.f-INDEX-FIELD =
       substitute("&1&2~"attr-code~" ASCENDING",tt-Index.f-INDEX-FIELD,chr(4)).
     vArea = tt-Index.f-AREA.
   end.
   create tt-Index.
   assign
      tt-Index.f-mode        = "ADD"
      tt-Index.f-Table       = iTableName
      tt-Index.f-Name        = '"code-value"'
      tt-Index.f-AREA        = vArea
      tt-Index.f-INDEX-FIELD = '"attr-code" ASCENDING' + chr(4) + '"attr-value" ASCENDING'
   .
end method.
method private void addindexHist(iTableName as character ):
   define buffer buf_tt-Index for tt-Index.
   for each tt-Index where tt-Index.f-localIndex ne 0  :
      create buf_tt-Index.
      buffer-copy tt-Index except f-PRIMARY f-UNIQUE f-localIndex  f-Name to buf_tt-Index
      assign
      buf_tt-Index.f-Name = '"' + trim(tt-Index.f-Name,'"') + '-2"'
      .
      assign
         buf_tt-Index.f-INDEX-FIELD = buf_tt-Index.f-INDEX-FIELD
                                                      + chr(4) + '"corr-date" ASCENDING'
                                                      + chr(4) + '"corr-time" ASCENDING'
                                                      + chr(4) + '"corr-user-db-num" ASCENDING'
             tt-Index.f-INDEX-FIELD =     tt-Index.f-INDEX-FIELD
                                                      + chr(4) + '"corr-user-db-num" ASCENDING'
                                                      + chr(4) + '"chip-num" ASCENDING'
      .
   end.
   create tt-Index.
   assign
      tt-Index.f-mode        = "ADD"
      tt-Index.f-Table       = iTableName
      tt-Index.f-Name        = '"corr-user-db-num"'
      tt-Index.f-AREA        = '"History_Index"'
      tt-Index.f-INDEX-FIELD = '"corr-user-db-num" ASCENDING'
   .
   create tt-Index.
   assign
      tt-Index.f-mode        = "ADD"
      tt-Index.f-Table       = iTableName
      tt-Index.f-Name        = '"corr-user-name"'
      tt-Index.f-AREA        = '"History_Index"'
      tt-Index.f-INDEX-FIELD = '"corr-user-name" ASCENDING' + chr(4) + '"corr-user-db-num" ASCENDING'
   .
end method.
method private void addFieldAttr(iTableName as character ):
   define variable vORDER    as integer no-undo init 0.
   define variable vPOSITION as integer no-undo init 1.
   for each tt-FIELD where tt-FIELD.f-table eq iTableName
       by int(tt-FIELD.f-ORDER):
      assign
        vPOSITION                              = vPOSITION + 1
       tt-FIELD.f-POSITION   = string(vPOSITION)
      .
   end.
   for each tt-FIELD where tt-FIELD.f-table eq iTableName
       by int(tt-FIELD.f-POSITION):
      assign
      vORDER                                  = vORDER + 10
      tt-FIELD.f-ORDER      = string (vORDER)
      .
   end.
   create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       ='"attr-code"'
      tt-FIELD.f-Data-Type  = "character"
      tt-FIELD.f-FORMAT     = '"X(8)"'
      tt-FIELD.f-INITIAL    = '""'
      tt-FIELD.f-LABEL       = '"Код атрибута"'
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-MAX-WIDTH  = "16"
      tt-FIELD.f-ORDER      = string (vORDER)
      tt-FIELD.f-MANDATORY  = "логическое_поле"
   .
   create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       ='"attr-value"'
      tt-FIELD.f-Data-Type  = "character"
      tt-FIELD.f-FORMAT     = '"X(20)"'
      tt-FIELD.f-INITIAL    = '""'
      tt-FIELD.f-LABEL       = '"Значение атрибута"'
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-MAX-WIDTH  = "40"
      tt-FIELD.f-ORDER      = string (vORDER)
   .
end method.
method private void addFieldHist(iTableName as character, iIsHead as logical ):
   define variable vORDER    as integer no-undo.
   define variable vPOSITION as integer no-undo.
   for each tt-FIELD where tt-FIELD.f-table eq iTableName:
      assign
         vORDER    = max(vORDER   ,int(tt-FIELD.f-ORDER    ))
         vPOSITION = max(vPOSITION,int(tt-FIELD.f-POSITION ))
      .
   end.
   assign
      vORDER    = max(vORDER,1000)
      vPOSITION = max(vPOSITION,100)
   .
   create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       ='"chip-num"'
      tt-FIELD.f-Data-Type  = "integer"
      tt-FIELD.f-FORMAT     = '"->,>>>,>>9"'
      tt-FIELD.f-INITIAL    = '"0"'
      tt-FIELD.f-LABEL       = '"Уникальный код"'
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-MAX-WIDTH  = "4"
      tt-FIELD.f-ORDER      = string (vORDER)
      tt-FIELD.f-MANDATORY  = "логическое_поле"
   .
   create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       = '"corr-date"'
      tt-FIELD.f-Data-Type  = "date"
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-ORDER      = string (vORDER)
      tt-FIELD.f-FORMAT     = '"99/99/99"'
      tt-FIELD.f-INITIAL    = '?'
      tt-FIELD.f-LABEL       = '"Дата действия"'
      tt-FIELD.f-MAX-WIDTH  = '4'
   .
   create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       = '"corr-time"'
      tt-FIELD.f-Data-Type  = "integer"
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-ORDER      = string (vORDER)
      tt-FIELD.f-FORMAT     = '"->,>>>,>>9"'
      tt-FIELD.f-INITIAL    = '"0"'
      tt-FIELD.f-LABEL       = '"Время действия"'
      tt-FIELD.f-MAX-WIDTH  = '4'
   .
   create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       = '"corr-user-db-num"'
      tt-FIELD.f-Data-Type  = "integer"
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-ORDER      = string (vORDER)
      tt-FIELD.f-FORMAT     = '"->,>>>,>>9"'
      tt-FIELD.f-INITIAL    = '"0"'
      tt-FIELD.f-LABEL       = '"ДБ создания"'
      tt-FIELD.f-MAX-WIDTH  = '4'
      tt-FIELD.f-MANDATORY  = "логическое_поле"
   .
   create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       = '"corr-user-name"'
      tt-FIELD.f-Data-Type  = "character"
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-ORDER      = string (vORDER)
      tt-FIELD.f-FORMAT     = '"x(8)"'
      tt-FIELD.f-INITIAL    = '""'
      tt-FIELD.f-LABEL       = '"Изменил"'
      tt-FIELD.f-MAX-WIDTH  = '16'
  .
  create tt-FIELD.
   assign
      vORDER                                  = vORDER + 10
      vPOSITION                               = vPOSITION + 1
      tt-FIELD.f-localIndex = 1
      tt-FIELD.f-mode       = "ADD"
      tt-FIELD.f-Table      = iTableName
      tt-FIELD.f-Name       = '"action"'
      tt-FIELD.f-Data-Type  = "integer"
      tt-FIELD.f-POSITION   = string(vPOSITION)
      tt-FIELD.f-ORDER      = string (vORDER)
      tt-FIELD.f-DESCRIPTION =  '"Описание действия"'
      tt-FIELD.f-FORMAT      = '"99"'
      tt-FIELD.f-INITIAL     = '"0"'
      tt-FIELD.f-LABEL       = '"Описание действия"'
      tt-FIELD.f-MAX-WIDTH   = '4'
   .
   if iIsHead then
   do:
       create tt-FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          tt-FIELD.f-localIndex = 1
          tt-FIELD.f-mode       = "ADD"
          tt-FIELD.f-Table      = iTableName
          tt-FIELD.f-Name       = '"subject"'
          tt-FIELD.f-Data-Type  = "character"
          tt-FIELD.f-POSITION   = string(vPOSITION)
          tt-FIELD.f-ORDER      = string (vORDER)
          tt-FIELD.f-FORMAT     = '"X(8)"'
          tt-FIELD.f-INITIAL    = '""'
          tt-FIELD.f-LABEL      = '"Предмет изменения"'
          tt-FIELD.f-MAX-WIDTH  = '16'
          tt-FIELD.f-MANDATORY  = "логическое_поле"
       .
       create tt-FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          tt-FIELD.f-localIndex = 1
          tt-FIELD.f-mode       = "ADD"
          tt-FIELD.f-Table      = iTableName
          tt-FIELD.f-Name       = '"is-news"'
          tt-FIELD.f-Data-Type  = "logical"
          tt-FIELD.f-POSITION   = string(vPOSITION)
          tt-FIELD.f-ORDER      = string (vORDER)
          tt-FIELD.f-FORMAT     = '"yes/no"'
          tt-FIELD.f-INITIAL    = '"no"'
          tt-FIELD.f-LABEL      = '"Прием по новостям"'
          tt-FIELD.f-MAX-WIDTH  = '1'
       .
       create tt-FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          tt-FIELD.f-localIndex = 1
          tt-FIELD.f-mode       = "ADD"
          tt-FIELD.f-Table      = iTableName
          tt-FIELD.f-Name       = '"source-type"'
          tt-FIELD.f-Data-Type  = "character"
          tt-FIELD.f-POSITION   = string(vPOSITION)
          tt-FIELD.f-ORDER      = string (vORDER)
          tt-FIELD.f-FORMAT     = '"X(8)"'
          tt-FIELD.f-INITIAL    = '""'
          tt-FIELD.f-LABEL      = '"Источник изменения"'
          tt-FIELD.f-MAX-WIDTH  = '16'
       .
       create tt-FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          tt-FIELD.f-localIndex = 1
          tt-FIELD.f-mode       = "ADD"
          tt-FIELD.f-Table      = iTableName
          tt-FIELD.f-Name       = '"source-ref"'
          tt-FIELD.f-Data-Type  = "character"
          tt-FIELD.f-POSITION   = string(vPOSITION)
          tt-FIELD.f-ORDER      = string (vORDER)
          tt-FIELD.f-FORMAT     = '"X(8)"'
          tt-FIELD.f-INITIAL    = '""'
          tt-FIELD.f-LABEL      = '"Ссылка на источник"'
          tt-FIELD.f-MAX-WIDTH  = '16'
       .
   end.
   else do:
       create tt-FIELD.
       assign
          vORDER                                  = vORDER + 10
          vPOSITION                               = vPOSITION + 1
          tt-FIELD.f-localIndex = 1
          tt-FIELD.f-mode       = "ADD"
          tt-FIELD.f-Table      = iTableName
          tt-FIELD.f-Name       = '"is-del"'
          tt-FIELD.f-Data-Type  = "logical"
          tt-FIELD.f-POSITION   = string(vPOSITION)
          tt-FIELD.f-ORDER      = string (vORDER)
          tt-FIELD.f-FORMAT     = '"yes/no"'
          tt-FIELD.f-INITIAL    = '"no"'
          tt-FIELD.f-LABEL      = '""'
          tt-FIELD.f-MAX-WIDTH  = '16'
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
   if not can-find(first tt-TABLE where tt-TABLE.f-Name = '"' + iTableName + '"') then
   do:
     empty temp-table tt-TABLE.
     empty temp-table tt-FIELD.
     empty temp-table tt-Index.
     empty temp-table tt-SEQUENCE.
     run prodict/dump_df.p   (iTableName,
                              iTableName + ".df",
                              "").
     readDF(iTableName + ".df").
   end.
   define variable vnewName   as character no-undo.
   define variable vnewNameno as character no-undo.
   for each tt-TABLE where not ( tt-TABLE.f-Name begins "c-") :
      vnewNameno = "c-" + trim(tt-TABLE.f-Name,'"').
      vnewName = '"' + vnewNameno + '"'.
      ChangeTable(tt-TABLE.f-Name,vnewName).
      tt-TABLE.f-Area = '"History"'.
      ChangeAreahist (vnewName).
      if iFileTrigger <> "" then
      do:
        crTriggerFile (vnewNameno, iFileTrigger, "WRITE").
        crTriggerFile (vnewNameno, iFileTrigger, "DELETE").
        tt-TABLE.f-TABLE-TRIGGER = substitute(
          "~"DELETE~" OVERRIDE PROCEDURE ~"trg/&1d.p~" CRC ~"?~"~
&2~"WRITE~" OVERRIDE PROCEDURE ~"trg/&1w.p~" CRC ~"?~"",
          iFileTrigger, chr(4)).
      end.
      else
      do:
        tt-TABLE.f-TABLE-TRIGGER = "".
      end.
      addFieldHist (vnewName, false).
      addIndexHist (vnewName).
      tt-TABLE.f-Name     = vnewName.
      tt-TABLE.f-DUMP-NAME = '"' + lc(vnewNameno) + '"'.
      if iCrSeq then
      do:
        create tt-SEQUENCE.
        assign
          tt-SEQUENCE.f-mode           = "ADD"
          tt-SEQUENCE.f-Name           = "s-" + vnewNameno + "-chip-num"
          tt-SEQUENCE.f-INITIAL        = '0'
          tt-SEQUENCE.f-INCREMENT      = '1'
          tt-SEQUENCE.f-CYCLE-ON-LIMIT = 'no'
        .
      end.
   end.
   dumpTable ("c-" + iTableName + ".df").
   if not noMessage then
     message "c-" + iTableName + ".df" search("c-" + iTableName + ".df")
     view-as alert-box.
 end method.
method public void crTableHeadHist
   ( iTableName    as character
   , iTableHead    as character
   , iSequenceName as character
   , iFileTrigger  as character):
   empty temp-table tt-TABLE.
   empty temp-table tt-FIELD.
   empty temp-table tt-Index.
   empty temp-table tt-SEQUENCE.
   run prodict/dump_df.p   (iTableName,
                            iTableName + ".df",
                            "").
   readDF(iTableName + ".df").
   define variable vnewName   as character no-undo.
   define variable vnewNameno as character no-undo.
   for each tt-TABLE where not ( tt-TABLE.f-Name begins "c-") :
      vnewNameno = trim(iTableHead).
      vnewName = '"' + vnewNameno + '"'.
      DeleteFieldsForHeadTable(tt-TABLE.f-Name).
      ChangeTable(tt-TABLE.f-Name,vnewName).
      tt-TABLE.f-Area = '"History"'.
      ChangeAreahist (vnewName).
      if iFileTrigger <> "" then
      do:
        crTriggerFile (vnewNameno, iFileTrigger, "WRITE").
        crTriggerFile (vnewNameno, iFileTrigger, "DELETE").
        tt-TABLE.f-TABLE-TRIGGER = substitute(
          "~"DELETE~" OVERRIDE PROCEDURE ~"trg/&1d.p~" CRC ~"?~"~
&2~"WRITE~" OVERRIDE PROCEDURE ~"trg/&1w.p~" CRC ~"?~"",
          iFileTrigger, chr(4)).
      end.
      else
      do:
        tt-TABLE.f-TABLE-TRIGGER = "".
      end.
      addFieldHist (vnewName, true).
      addIndexHeadHist (vnewName).
      tt-TABLE.f-Name     = vnewName.
      tt-TABLE.f-DUMP-NAME = '"' + lc(vnewNameno) + '"'.
      create tt-SEQUENCE.
      assign
         tt-SEQUENCE.f-mode           = "add"
         tt-SEQUENCE.f-Name           = trim(iSequenceName)
         tt-SEQUENCE.f-INITIAL        = '0'
         tt-SEQUENCE.f-INCREMENT      = '1'
         tt-SEQUENCE.f-CYCLE-ON-LIMIT = 'no'
      .
   end.
   dumpTable (iTableHead + ".df") no-error.
   if not noMessage then
     message iTableHead + ".df" search(iTableHead + ".df")
     view-as alert-box.
end method.
method public void crTableAttr (
   iTableName       as character,
   iFileTrigger     as character,
   iCrHistAttr      as logical,
   iFileTriggerHist as character):
   define variable vnewName   as character no-undo.
   define variable vnewNameno as character no-undo.
   empty temp-table tt-TABLE.
   empty temp-table tt-FIELD.
   empty temp-table tt-Index.
   empty temp-table tt-SEQUENCE.
   run prodict/dump_df.p   (iTableName,
                            iTableName + ".df",
                            "").
   readDF(iTableName + ".df").
   for each tt-TABLE where not ( tt-TABLE.f-Name begins "c-") :
      vnewNameno = trim(iTableName) + "-attr".
      vnewName = '"' + vnewNameno + '"'.
      DeleteFieldsForHeadTable(tt-TABLE.f-Name).
      ChangeTable(tt-TABLE.f-Name,vnewName).
      if iFileTrigger <> "" then
      do:
        crTriggerFile (vnewNameno, iFileTrigger, "WRITE").
        crTriggerFile (vnewNameno, iFileTrigger, "DELETE").
        tt-TABLE.f-TABLE-TRIGGER = substitute(
          "~"DELETE~" OVERRIDE PROCEDURE ~"trg/&1d.p~" CRC ~"?~"~
&2~"WRITE~" OVERRIDE PROCEDURE ~"trg/&1w.p~" CRC ~"?~"",
          iFileTrigger, chr(4)).
      end.
      else
      do:
        tt-TABLE.f-TABLE-TRIGGER = "".
      end.
      addFieldAttr (vnewName).
      addIndexAttr (vnewName).
      tt-TABLE.f-Name     = vnewName.
      tt-TABLE.f-DUMP-NAME = '"' + lc(vnewNameno) + '"'.
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
