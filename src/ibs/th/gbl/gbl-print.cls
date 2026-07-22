/*

$Revision: b10ceb95d184, 3329, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:08 $
$Workfile: gbl-print.cls $
$Archive: ibs/th/gbl/gbl-print.cls $

Статический класс со значениями параметров из ini-файла

Автор: Молотков Сергей
Дата создания: 14/02/18
Author: Molotkov Sergey
Creation date: 14/02/18

*/
/* 03/VIII-2018 Временно добавлены переменные для печати, чтобы исключить использование prn-lib.i.
                Из ini-файла не берутся.
                Когда их здесь наберётся достаточно много - подумаем, куда их вынести.
*/   

using ibs.th.gbl.sys.*.
block-level on error undo, throw.
class ibs.th.gbl.gbl-print inherits objth: 
define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Статусы электронных документов" get.

  { cmp/str-glbl.i class }
   constructor gbl-print():
    super ( ) .
  end constructor.

 

  /* ----- переменные для печати ----- */
  define private variable cntxt-report-num as integer no-undo initial 0 .
/*     для формирования имени файла отчетов - обеспечивает уникальность имён временных файлов между сессиями*/
     
  method public character prn-lib-get-report-name ( ) :
  define variable v-report-name as character no-undo .
    v-report-name = prn-lib-get-report-name ("rpt") .
    return v-report-name .
  end method.
  method public character prn-lib-get-report-name (input p-df-name as character) :
  define variable v-report-name as character no-undo .
    assign
      cntxt-report-num = dynamic-next-value( "next-report":U, "ubflt":U ) when cntxt-report-num = 0
    .
    v-report-name = substitute("&1&2&3", session:temp-directory, p-df-name, cntxt-report-num ) .
    return v-report-name .
  end method.

  method public void prn-lib-reportviewer-report-name (input p-report-name-html as character) :
     define variable v-full-path-RepView as character no-undo.
     define variable ii                  as integer no-undo .
     define variable v-report-name       as character no-undo .
  
    /* Получение полного пути к исполняемому файлу просмотровщика отчётов RV.exe */
     if search("exe\ReportViewer\reportviewer.exe") <> ? then
     do:
       v-full-path-RepView = search("exe\ReportViewer\reportviewer.exe").
     end.
     else
     do:
       message "Не найдена программа просмотра отчёта!" view-as alert-box error.
     end.
   
     do ii = 1 to NUM-ENTRIES (p-report-name-html).
       v-report-name = ENTRY (ii,p-report-name-html," ").
       if search(v-report-name) = ? then
       do:
         message "Не найден файл отчёта: " v-report-name view-as alert-box error.
         return error.
       end.
     end.
   
     os-command no-wait value(v-full-path-RepView + " true " + p-report-name-html).
  end method.
    
  method public void prn-lib-reportviewer (input p-report-name-html as character, 
  input p-param as character) :
    
   define variable ii                  as integer   no-undo .
   define variable jj                  as integer   no-undo .
   define variable v-report-name       as character no-undo .
   define variable v-fill-path-RepView as character no-undo.
   define variable v-param             as character no-undo .
   define variable v-GUI               as character no-undo init 'TRUE' .
   define variable v-password          as character no-undo init 'FALSE'.
   define variable v-par               as character no-undo .
   define variable v-path              as character no-undo .
   define variable v-os                as character no-undo .
   define variable v-command           as character no-undo .
   define variable v-excel             as character no-undo init 'TRUE' .
   define variable v-silent            as character no-undo init 'FALSE' .

   do ii = 1 to NUM-ENTRIES (p-report-name-html):
      v-report-name = ENTRY (ii,p-report-name-html," ").
      if search(v-report-name) = ? then
      do:
         return error "Не найден файл отчёта: " + v-report-name.
      end.
   end.

      GET-KEY-VALUE section "REP-SETS" key "rep_excel" value v-excel .
      if v-excel eq ? 
         then 
         v-excel = "".
      else 
      do:
         case v-excel:
            when 'TRUE' then 
               v-excel = 'TRUE' .
            when 'YES'  then 
               v-excel = 'TRUE' .
            otherwise 
            v-excel = 'FALSE' .
         end case .   
      end.   
      GET-KEY-VALUE section "REP-SETS" key "Password" value v-password .  
      if v-password = ? then v-password = "FALSE" .
      else 
      do:
         case v-password:
            when 'TRUE' then 
               v-password = 'TRUE' .
            when 'YES'  then 
               v-password = 'TRUE' .
            otherwise 
            v-password = 'FALSE' .
         end case .        
      end.   

   do jj = 1 to NUM-ENTRIES (p-param,{&delim-par}):
      v-par = entry (jj,p-param,{&delim-par}) .
      if num-entries(v-par,':') <> 2 then return error 'Не правильно переданы параметры'.
      case entry(1,v-par,':':U):
         when 'GUI' then 
            v-GUI = entry(2,v-par,':'). /*открывать репорт или нет*/
         when 'Password' then 
            v-password = entry(2,v-par,':'). /*требовать пароль*/
         when 'OS' then 
            v-os = entry(2,v-par,':'). /*версия*/
         when 'EXCEL' then 
            v-excel = entry(2,v-par,':'). /*при нажатии печать печатает через excel*/
      end case.
   end.   
   v-path = "exe\ReportViewer\reportviewer.exe" .
              
   if search(v-path) <> ? then
   do:
      v-fill-path-RepView = search(v-path).
   end.
   else
   do:
      return error "Не найдена программа просмотра отчёта!" .
   end.

   v-command = substitute('&1 &2 &3 &4 &5 ',v-fill-path-RepView,v-GUI,v-password,v-excel,p-report-name-html).            
   if v-GUI = 'False'
   then
      os-command SILENT value(v-command). 
   else
      os-command no-wait value(v-command).
end method.
  /* ----- end_of переменные для печати ----- */   
  
end class.