/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры открытия закрытия EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 03/21/06
Author: Svetlana Chernova
Creation date: 03/21/06

*/
&if "{1}" <> ""
&then
method public void OpenForExcel():
&else
procedure OpenForExcel :
&endif
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              {&DF_Name} + string( {1}{2}g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              {&DF_Name} + string( {1}{2}g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              {&DF_Name} + string( {1}{2}g#report-num ) + ".txl":U ) .


   if {1}Make-Excel 
   then do:

      output stream ForExcel to value( string( session:temp-directory +
                                     {&DF_Name} + string( {1}{2}g#report-num ) + ".txt":U ) ) .
      assign
         {1}v-excel-file = string( session:temp-directory + {&DF_Name} + string( {1}{2}g#report-num ) )
         {1}number-list = 1
      .
      if {1}make-excel-com 
      then do:
         { cmp/relescom.i {1}ch#WorkSheet }
         { cmp/relescom.i {1}ch#Workbook }
         { cmp/relescom.i {1}ch#ExcelApplication }

         create "Excel.Application" {1}ch#excelApplication connect no-error.
         if error-status:error 
         then do :
        create "Excel.Application" {1}ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.  
         end.
         assign
            {1}num#str#  = 0.
            v-ch#excelApplication  = {1}ch#excelApplication. 
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            {1}ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            {1}ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = {1}ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = {&xlLeft}.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = {&xlTop} 
         no-error .
         if error-status:error 
         then do:
            {1}Make-Excel-com = false .
            {1}Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           {&DF_Name} + string( {1}{2}g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           {&DF_Name} + string( {1}{2}g#report-num ) + ".frm":U ) .

            return.
         end.
      end.
   end.
end.

&if "{1}" <> ""
&then
method public void CloseForExcel():
&else
procedure CloseForExcel :
&endif   
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo. 

   if {1}Make-Excel 
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             {&DF_Name} + string( {1}{2}g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             {&DF_Name} + string( {1}{2}g#report-num ) + ".frm":U ) .
      &if "{1}" <> ""
      &then
      vsheet-num = {1}sheet-num.
      &else                   
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf 
      then
         vsheet-num = buf_sheetf.sheet-num.
      &endif
      if vsheet-num > 1 
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  {&DF_Name} + string( {1}{2}g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
      
      { cmp/relescom.i {1}ch#WorkSheet }
      { cmp/relescom.i {1}ch#Workbook }
      { cmp/relescom.i {1}ch#ExcelApplication }

   end.
end.
/* $Workfile$ e n d */