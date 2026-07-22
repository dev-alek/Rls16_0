using Progress.Lang.*.
using ibs.th.gbl.sys.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.execlimpexp inherits objth:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property  vss-description as character no-undo init "Класс импорта экспорта Эксель" get.
   define property PublisHandle as handle no-undo
   get.
   set.
   constructor public execlimpexp (  ):
      super ().
   end constructor.
   constructor public execlimpexp ( iPublisHandle as handle  ):
      super ().
      PublisHandle = iPublisHandle.
   end constructor.
   define stream OutStr-html.
   method public  char expToExcel(htt as  handle):
      define variable vFile  as character no-undo.
      vfile = htt:name + ".html".
      expToExcel(htt,vFile).
      return vfile.
   end.
   method public  void expToExcel(ihandle as  handle, ifile as char):
      define variable vItm as integer  no-undo.
      define variable vhBuffer as handle no-undo.
      define variable vhQry as handle no-undo.
      define variable vhField as handle no-undo.
      if ihandle:type eq "temp-table"
      then
         vhBuffer = ihandle:default-buffer-handle.
      else if ihandle:type eq "buffer"
      then
         vhBuffer = ihandle.
      else if ihandle:type eq "query"
      then do:
         vhBuffer = ihandle:get-buffer-handle(ihandle:num-buffers).
         vHQry = ihandle.
      end.
      else do:
         putmes("Недопустимый тип handle возможные хандлы temp-table или buffer или query").
         return.
      end.
      if vhBuffer eq ?
      then do:
         putmes("Не удалось определить буфер для работы").
         return.
      end.
      output stream OutStr-html to value(ifile) convert target 'UTF-8' .
      put stream OutStr-html unformatted
"<!DOCTYPE HTML>" skip
' <html>' skip
'  <head>' skip
'   <meta charset="utf-8">' skip
'    <style type="text/css">' skip
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
'   </style>' skip
'  </head>' skip
         '<body>' skip
         '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
         '<thead>' skip
         ' <tr class="set_columns">' skip.
      do vItm = 1 to vhBuffer:num-fields:
         vhField = vhBuffer:buffer-field(vItm).
         if vhField:name ne "NumLine_"
         then
            put stream OutStr-html unformatted
            ' <td style="width:' + formatToPx(vhField:format, length (getFieldName(vhField))) + 'px"></td>' skip.
      end.
      put stream OutStr-html unformatted
         '</tr>' skip
         '</thead>' skip
         '<tr>' skip.
      do vItm = 1 to vhBuffer:num-fields:
         vhField = vhBuffer:buffer-field(vItm).
         if vhField:name ne "NumLine_"
         then
            put stream OutStr-html unformatted
              '<td text_wrap="true" style=" text-align: center; border: 1px solid black;">' + getFieldName(vhField) + '</td>' skip.
      end.
      put stream OutStr-html unformatted
         '</tr>'   skip
         '<tbody>' skip
      .
      if not valid-handle (vHQry)
      then do:
         create query  vHQry.
         vhQry:set-buffers (vhBuffer).
         vHQry:query-prepare ("FOR EACH " + vhBuffer:name + "  NO-LOCK").
      end.
      vHQry:query-open ().
      repeat:
         vHQry:get-next ().
         if vHQry:query-off-end
         then leave .
         put stream OutStr-html unformatted
            '<tr>' skip.
         do vItm = 1 to vhBuffer:num-fields:
            vhField = vhBuffer:buffer-field(vItm).
            if vhField:name ne "NumLine_"
            then
               put stream OutStr-html unformatted
                  '<td text_wrap="true">' vhField:buffer-value '</td>' skip.
         end.
         put stream OutStr-html unformatted
            '</tr>' skip.
      end.
      vhQry:query-close ().
      put stream OutStr-html unformatted
         '<tbody>' skip
         '</table>'
      .
      output stream OutStr-html close.
      delete object vhQry.
      ObjSrv:Lib:prnLib:prn-lib-reportviewer(ifile, "GUI:FALSE").
   end.
   method public handle impExcel(ifile   as character,
                                 iNumCol as integer  ):
      define variable tth as handle no-undo.
      define variable vi as integer no-undo.
      create temp-table tth.
      do vi = 1 to iNumCol:
         tth:add-new-field ("Col_" + string(vi), "char").
      end.
      tth:add-new-field ("NumLine_", "char").
      tth:add-new-index("NumLine_", false, true).
      tth:add-index-field("NumLine_", "NumLine_").
      tth:temp-table-prepare ("tt-col-" + string(iNumCol)).
      impExcel(ifile,tth).
      return tth.
   end.
   method public void impExcel (iFile     as character,
                                ihandle   as  handle):
      define variable vItm     as integer  no-undo.
      define variable vhBuffer as handle   no-undo.
      define variable mExcelApplication as component-handle no-undo.
      define variable mWorkBook         as component-handle no-undo.
      define variable mWorkSheet        as component-handle no-undo.
      define variable vhField      as handle no-undo.
      define variable vValue       as character no-undo.
      define variable vChLine      as integer   no-undo.
      define variable vCorectItem  as integer   no-undo.
      define variable vCorectLine  as integer   no-undo.
      define variable vAvailLine   as logical   no-undo.
      define variable vNextLine    as logical   no-undo.
      if ihandle:type eq "temp-table"
      then
         vhBuffer = ihandle:default-buffer-handle.
      else if ihandle:type eq "buffer"
      then
         vhBuffer = ihandle.
      else do:
         putmes("Недопустимый тип handle возможные хандлы temp-table or buffer").
         return.
      end.
      create "Excel.Application":U mExcelApplication no-error.
      if error-status :error then do:
         putmes(substitute ("Ошибка при запуске Excel: &1",error-status :get-message(1))).
         return.
      end.
      assign
         mExcelApplication:DisplayAlerts = no
         mWorkbook                       = mExcelApplication:WorkBooks:Add(iFile)
         mWorkSheet                      = mWorkbook:Sheets:Item(1)
      .
      Block-Line:
      do on error   undo Block-Line, leave Block-Line
         on end-key undo Block-Line, leave Block-Line
      while true:
         vChLine = vChLine + 1.
         vhBuffer:buffer-create ().
         assign
            vCorectItem = 0
            vAvailLine  = no
            vNextLine   = no
         .
         do vItm = 1 to vhBuffer:num-fields:
            vhField = vhBuffer:buffer-field(vItm).
            if vhField:name ne "NumLine_"
            then do:
               vValue = ?.
               vValue = mWorkSheet:Range(f-range(vItm - vCorectItem) + string(vChLine)):VALUE no-error.
               if vValue = ? then vValue = mWorkSheet:Range(f-range(vItm - vCorectItem) + string(vChLine)):FORMULA no-error.
               if     vValue ne ""
                  and vValue ne ?
               then do:
                  if vValue = getFieldName(vhField)
                  then do:
                     vNextLine = yes.
                     vhField:buffer-value = vValue no-error.
                  end.
                  else do:
                     vAvailLine           = yes.
                     vhField:buffer-value = vValue no-error.
                     if error-status:error
                     then
                        putmes(substitute ("В ячейке &1 не удается преобразовать &2 в &3: &4",f-range(vItm - vCorectItem) + string(vChLine),vValue,vhField:data-type, error-status:get-message (1))).
                  end.
               end.
            end.
            else do:
               vCorectItem = vCorectItem  + 1.
               vhField:buffer-value = vChLine + vCorectLine.
            end.
         end.
         if vNextLine and not vAvailLine
         then do:
            vhBuffer:buffer-delete ().
            vCorectLine = vCorectLine - 1.
         end.
         else if not vAvailLine
         then do:
            vhBuffer:buffer-delete ().
            vChLine = vChLine - 1.
            leave.
         end.
         else do:
            define variable vDelLine as logical no-undo.
            if valid-handle (PublisHandle)
            then do:
               publish "WorkLineExel" from PublisHandle (vhBuffer,output vDelLine).
               if vDelLine
               then
                  vhBuffer:buffer-delete ().
            end.
         end.
      end.
      release object mWorkSheet no-error.
      release object mWorkbook no-error.
      mExcelApplication :QUIT().
      release object mExcelApplication.
   end method.
   method public character  formatToPx(iformat as character, imin as int):
      define variable vColChar as integer no-undo.
      if iformat begins "x("
      then
         vColChar = integer (substring (iformat,3,length (iformat) - 3)).
      else
         vColChar = length (iformat).
      vColChar = max(vColChar,imin).
      return string (11 * vColChar).
   end method.
   method public character  getFieldName(ifield as handle ):
      return if     ifield:label ne ""
                and ifield:label ne ?
             then ifield:label
             else if     ifield:column-label ne ""
                     and ifield:column-label ne ?
             then ifield:column-label
             else ifield:name.
   end method.
   method public character f-range (input p-num as integer) :
      case p-num :
         when 1 then return "A":U .
         when 2 then return "B":U .
         when 3 then return "C":U .
         when 4 then return "D":U .
         when 5 then return "E":U .
         when 6 then return "F":U .
         when 7 then return "G":U .
         when 8 then return "H":U .
         when 9 then return "I":U .
         when 10 then return "J":U .
         when 11 then return "K":U .
         when 12 then return "L":U .
         when 13 then return "M":U .
         when 14 then return "N":U .
         when 15 then return "O":U .
         when 16 then return "P":U .
         when 17 then return "Q":U .
         when 18 then return "R":U .
         when 19 then return "S":U .
         when 20 then return "T":U .
      end case .
   end method.
   method public void putmes (input itext as char):
      if valid-handle (PublisHandle)
      then
         publish "WriteLogExel" from PublisHandle (itext).
   end.
   destructor public execlimpexp ( ):
   end destructor.
end class.
