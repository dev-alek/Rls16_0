block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: r-tobacco-marks.p $
$Archive: rep/r-tobacco-marks.p $

Утилита проверки целостности свободной зоны марок и восстановления

Автор: Шкляр Елена
Дата создания: 07/23/08
Author: Elena Shklyar
Creation date: 07/23/08

*/

define variable vss-revision    as character no-undo initial "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-tobacco-marks.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-tobacco-marks.p $":U .
define variable vss-description as character no-undo initial "Отчет по невалидным маркам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ ref/grplibfn.i }
{ ref/gds-attr.i }
{ gbl/waitfram.i }

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter p-group-pack      as logical no-undo .

    define buffer buf_clients  for ub.clients .
    define buffer buf_parts    for ub.parts .
    define buffer buf_goods    for ub.goods .
    define buffer buf_obj-list for obj-list.
    define buffer buf_gds-list for gds-list.
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking  for ub.marking .
    define buffer buf_gds-obj  for ub.gds-obj .
    
    define VARIABLE v-count-mark              as INTEGER   no-undo .
    define VARIABLE v-alc-code                as character no-undo .
    define variable v-parts-income            as character no-undo .
    define variable v-parts-expence           as character no-undo .
    define variable v-parts-free              as character no-undo .
    define variable hndl-proc-egais-marks-lib as handle.
    define VARIABLE v-mark                    as character no-undo .
    define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
    define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
    define variable g#report-num as integer no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
    define variable v-report-name as character no-undo.         /* Наименование отчёта */
    define VARIABLE v-rezerv                  as integer   no-undo .
    define VARIABLE ii                        as integer   no-undo .
    define VARIABLE jj                        as integer   no-undo .
    define VARIABLE v-in-code                 as character no-undo .
    define variable v-txt-name                as character no-undo initial 'r-tobacco-marks.log'. /* Имя лога */
    define VARIABLE v-attr-value              as character no-undo .
    define VARIABLE v-value                   as character no-undo .
    
    { gbl/objsrv.i }
   
    define stream str-marks .
    define stream OutStr-html.

    define temp-table tt-goods
      field gds-code  as integer
      field gds-name as character
      field obj-type  as character
      field obj-code as integer
      field free-qnty as decimal
      field ok-grp-marks as integer
      field ok-unit-marks as integer
      field ok-korob-marks as integer
      field err-grp-marks as integer
      field err-unit-marks as integer
      field tech-marks as integer
      field err-korob-marks as integer
      index pi as unique primary
        gds-code obj-type obj-code
    .
    define buffer buf_tt-goods for tt-goods . 
    
    define variable obj-free-qnty       as decimal no-undo .
    define variable obj-ok-grp-marks    as integer no-undo .
    define variable obj-ok-unit-marks   as integer no-undo .
    define variable obj-err-grp-marks   as integer no-undo .
    define variable obj-err-unit-marks  as integer no-undo .
    define variable obj-tech-marks      as integer no-undo .
    
    /*определение товара*/
    for each buf_obj-list :
      case X-selectgood:
        when {&g-grp} then
            do:
                define variable v-curr-grp-name as character no-undo .
                for each tmp#grp no-lock
                    :
                    run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
                    for each buf_goods no-lock where buf_goods.grp-name begins v-curr-grp-name:

                        RUN gds-attr-value (
                            INPUT buf_goods.gds-code,
                            INPUT {&attr-mark-type},
                            OUTPUT v-attr-value,
                            OUTPUT v-value
                            ).
                        if v-attr-value > ""
                        and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_obj-list.obj-type, buf_obj-list.obj-code):GetIsMarkingForType(v-attr-value) 
                        then do:
                            create tt-goods .
                            assign
                              tt-goods.gds-code   = buf_goods.gds-code
                              tt-goods.gds-name   = buf_goods.gds-name
                              tt-goods.obj-type   = buf_obj-list.obj-type
                              tt-goods.obj-code   = buf_obj-list.obj-code
                            .
                            v-attr-value = "" .  
                        end.  
                    end.
                end.
            end.
        when {&g-all} then
            do:
                for each buf_goods no-lock :
                    RUN gds-attr-value (
                        INPUT buf_goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-attr-value,
                        OUTPUT v-value
                        ).
                    if v-attr-value > ""
                    and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_obj-list.obj-type, buf_obj-list.obj-code):GetIsMarkingForType(v-attr-value) 
                    then do:
                        create tt-goods .
                        assign
                          tt-goods.gds-code   = buf_goods.gds-code
                          tt-goods.gds-name   = buf_goods.gds-name
                          tt-goods.obj-type   = buf_obj-list.obj-type
                          tt-goods.obj-code   = buf_obj-list.obj-code
                        .
                        v-attr-value = "" .
                    end.
                end.                
            end.

        when {&g-choice} or 
        when {&g-one} then                                          
            do:                                                                             
                for each buf_gds-list no-lock :
                    RUN gds-attr-value (
                        INPUT buf_gds-list.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-attr-value,
                        OUTPUT v-value
                        ).
                    if v-attr-value > ""
                    and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_obj-list.obj-type, buf_obj-list.obj-code):GetIsMarkingForType(v-attr-value) 
                    then do:
                        create tt-goods .
                        assign
                          tt-goods.gds-code   = buf_gds-list.gds-code
                          tt-goods.gds-name   = buf_gds-list.gds-name
                          tt-goods.obj-type   = buf_obj-list.obj-type
                          tt-goods.obj-code   = buf_obj-list.obj-code
                        .
                        v-attr-value = "" .
                    end.
                end.    
            end.                                                                            
      end case.
    end .

    for each buf_tt-goods exclusive-lock :
      /*марки свободной зоны*/
      for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf_tt-goods.gds-code
                                           and buf_marking-lines.obj-code = buf_tt-goods.obj-code
                                           and buf_marking-lines.obj-type = buf_tt-goods.obj-type
                                           and buf_marking-lines.out-code = {&free-code},
      first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark : 
        if buf_marking.mark begins {&tech-mark-prefix}
        then do :
          buf_tt-goods.tech-marks = buf_tt-goods.tech-marks + 1 .
        end .
        else do :
          case buf_marking.unit-ext :
            when "UNIT"
            then do :
              if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              then
                buf_tt-goods.err-unit-marks = buf_tt-goods.err-unit-marks + 1 .
              else
                buf_tt-goods.ok-unit-marks = buf_tt-goods.ok-unit-marks + 1 .
            end .
            when "LEVEL1"
            then do :
              if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              then
                buf_tt-goods.err-grp-marks = buf_tt-goods.err-grp-marks + 1 .
              else
                buf_tt-goods.ok-grp-marks = buf_tt-goods.ok-grp-marks + 1 .
            end .
            when "LEVEL2"
            then do :
              if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              then
                buf_tt-goods.err-korob-marks = buf_tt-goods.err-korob-marks + 1 .
              else
                buf_tt-goods.ok-korob-marks = buf_tt-goods.ok-korob-marks + 1 .
            end .
          end case .
        end .
      end. /*for each buf_marking-lines */
    end.
    for each buf_tt-goods exclusive-lock :
      if p-group-pack
      then do :
        if buf_tt-goods.ok-korob-marks > 0
        then do :
          assign
            buf_tt-goods.ok-grp-marks   = buf_tt-goods.ok-grp-marks  - (buf_tt-goods.ok-korob-marks  * 50)
            buf_tt-goods.err-grp-marks  = buf_tt-goods.err-grp-marks - (buf_tt-goods.err-korob-marks * 50)
            buf_tt-goods.ok-unit-marks  = buf_tt-goods.ok-unit-marks  - (buf_tt-goods.ok-korob-marks  * 500)
            buf_tt-goods.err-unit-marks = buf_tt-goods.err-unit-marks - (buf_tt-goods.err-korob-marks * 500)
          .
          assign
            buf_tt-goods.ok-grp-marks   = buf_tt-goods.ok-grp-marks  + buf_tt-goods.ok-korob-marks
            buf_tt-goods.err-grp-marks  = buf_tt-goods.err-grp-marks + buf_tt-goods.err-korob-marks
          .
        end .
        else do :
          assign
            buf_tt-goods.ok-unit-marks  = buf_tt-goods.ok-unit-marks  - (buf_tt-goods.ok-grp-marks  * 10)
            buf_tt-goods.err-unit-marks = buf_tt-goods.err-unit-marks - (buf_tt-goods.err-grp-marks * 10)
          .
        end .
      end .
      else do :
        assign
          buf_tt-goods.ok-korob-marks   = 0
          buf_tt-goods.err-korob-marks  = 0
          buf_tt-goods.ok-grp-marks     = 0
          buf_tt-goods.err-grp-marks    = 0
        .
      end .
    end .
    
    if p-group-pack
    then do :
      run my-report-group in this-procedure .
    end .
    else do :
      run my-report in this-procedure .
    end .
    
procedure my-report :
  
  run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

  run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

  run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */


  run waitfram-show in this-procedure ("Подождите ...").
  
  &scoped-define css_page1tit      text-align:center; font-weight:bold;
&scoped-define css_align_righit  text-align:right; padding-right:4px;
&scoped-define css_align_center  text-align:center;
&scoped-define css_table_border  border-style:solid; border-width:thin;
&scoped-define css_cell_border   border: 1px solid black; 
&scoped-define css_border_bottom border-bottom: 1px solid black;  

  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
  
  
  /* Системная шапка HTML */
  put stream OutStr-html unformatted
  "<!DOCTYPE HTML>" skip
  ' <html>' skip
  '  <head>' skip
  '   <meta charset="utf-8">' skip
  '    <style type="text/css">' skip
  '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
  '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
  '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
  '   </style>' skip
  '  </head>' skip
  .
    
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 90px;"></td>' skip
    '<td style="width: 140px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 110px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 140px;"></td>' skip
    '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="8" style="text-align: center; font-weight:bold;">Отчёт о состоянии остатков табачной продукции</td>' skip
    '</tr>' skip   
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">На дату ' + string(TODAY, "99/99/9999") + '</td>' skip
    '</tr>' skip  
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">Выбор товара:</td>' skip
    '</tr>' skip 
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">Выбор объекта:</td>' skip
    '</tr>' skip 
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
  .  
    
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Объект</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Код товара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование товара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Остаток (уч. ед. изм.)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Кол-во валидных КМ</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Кол-во невалидных КМ</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Кол-во немаркированных пачек (уч. ед. изм.)</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">7</th>' skip
      '       </tr>' skip
  . /* Точка для закрытия Put */
  
  for each buf_tt-goods no-lock break by buf_tt-goods.obj-type by buf_tt-goods.obj-code :
    if first-of(buf_tt-goods.obj-code)
    or first-of(buf_tt-goods.obj-code)
    then do :
      find first buf_clients no-lock where buf_clients.obj-type = buf_tt-goods.obj-type
                                       and buf_clients.obj-code = buf_tt-goods.obj-code
                                       .
      assign
        obj-free-qnty       = 0
        obj-ok-grp-marks    = 0
        obj-ok-unit-marks   = 0
        obj-err-grp-marks   = 0
        obj-err-unit-marks  = 0
        obj-tech-marks      = 0  
      .                              
    end .
    find first buf_gds-obj no-lock where buf_gds-obj.gds-code = buf_tt-goods.gds-code
                                     and buf_gds-obj.obj-type = buf_tt-goods.obj-type
                                     and buf_gds-obj.obj-code = buf_tt-goods.obj-code
                                     no-error .
    put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: left;">' + buf_clients.obj-name + '</th>' skip
      '         <th style="text-align: left;">' + string(buf_tt-goods.gds-code) + '</th>' skip
      '         <th style="text-align: left;">' + buf_tt-goods.gds-name + '</th>' skip
      '         <th style="text-align: center;">' + (if available (buf_gds-obj) then string(buf_gds-obj.free-qnty) else "0") + '</th>' skip
      '         <th style="text-align: center;">' + string(buf_tt-goods.ok-unit-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(buf_tt-goods.err-unit-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(buf_tt-goods.tech-marks) + '</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */
    
    assign
      obj-free-qnty       = obj-free-qnty + (if available (buf_gds-obj) then buf_gds-obj.free-qnty else 0)
      obj-ok-grp-marks    = obj-ok-grp-marks + buf_tt-goods.ok-grp-marks
      obj-ok-unit-marks   = obj-ok-unit-marks + buf_tt-goods.ok-unit-mark
      obj-err-grp-marks   = obj-err-grp-marks + buf_tt-goods.err-grp-marks
      obj-err-unit-marks  = obj-err-unit-marks + buf_tt-goods.err-unit-marks
      obj-tech-marks      = obj-tech-marks + buf_tt-goods.tech-marks  
    . 
    
    if last-of(buf_tt-goods.obj-code)
    or last-of(buf_tt-goods.obj-code)
    then do :
      put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th colspan="3" style="text-align: left;">Итого по объекту:</th>' skip
      '         <th style="text-align: center;">' + string(obj-free-qnty) + '</th>' skip
      '         <th style="text-align: center;">' + string(obj-ok-unit-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(obj-err-unit-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(obj-tech-marks) + '</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */
    end .
  end . /* for each tt-goods */
  put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
 . /* Точка для закрытия Put */
  output stream OutStr-html close.
  
  run waitfram-hide in this-procedure .
  
  run prn-lib-reportviewer-report-name in this-procedure (
  input THIS-PROCEDURE
  ,input v-file-name-rep-htm
  ).
  
  
end procedure .
    
procedure my-report-group :
  
  run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

  run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

  run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */


  run waitfram-show in this-procedure ("Подождите ...").
  
  &scoped-define css_page1tit      text-align:center; font-weight:bold;
&scoped-define css_align_righit  text-align:right; padding-right:4px;
&scoped-define css_align_center  text-align:center;
&scoped-define css_table_border  border-style:solid; border-width:thin;
&scoped-define css_cell_border   border: 1px solid black; 
&scoped-define css_border_bottom border-bottom: 1px solid black;  

  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
  
  
  /* Системная шапка HTML */
  put stream OutStr-html unformatted
  "<!DOCTYPE HTML>" skip
  ' <html>' skip
  '  <head>' skip
  '   <meta charset="utf-8">' skip
  '    <style type="text/css">' skip
  '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
  '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
  '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
  '   </style>' skip
  '  </head>' skip
  .
    
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 90px;"></td>' skip
    '<td style="width: 140px;"></td>' skip
    '<td style="width: 90px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 110px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 140px;"></td>' skip
    '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="8" style="text-align: center; font-weight:bold;">Отчёт о состоянии остатков табачной продукции</td>' skip
    '</tr>' skip   
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">На дату ' + string(TODAY, "99/99/9999") + '</td>' skip
    '</tr>' skip  
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">Выбор товара:</td>' skip
    '</tr>' skip 
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">Выбор объекта:</td>' skip
    '</tr>' skip 
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
  .  
    
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Объект</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Код товара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование товара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Тип упаковки</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Остаток (уч. ед. изм.)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Кол-во валидных КМ</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Кол-во невалидных КМ</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Кол-во немаркированных пачек (уч. ед. изм.)</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">7</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">8</th>' skip
      '       </tr>' skip
  . /* Точка для закрытия Put */
  
  for each buf_tt-goods no-lock break by buf_tt-goods.obj-type by buf_tt-goods.obj-code :
    if first-of(buf_tt-goods.obj-code)
    or first-of(buf_tt-goods.obj-code)
    then do :
      find first buf_clients no-lock where buf_clients.obj-type = buf_tt-goods.obj-type
                                       and buf_clients.obj-code = buf_tt-goods.obj-code
                                       .
      assign
        obj-free-qnty       = 0
        obj-ok-grp-marks    = 0
        obj-ok-unit-marks   = 0
        obj-err-grp-marks   = 0
        obj-err-unit-marks  = 0
        obj-tech-marks      = 0  
      .                              
    end .
    find first buf_gds-obj no-lock where buf_gds-obj.gds-code = buf_tt-goods.gds-code
                                     and buf_gds-obj.obj-type = buf_tt-goods.obj-type
                                     and buf_gds-obj.obj-code = buf_tt-goods.obj-code
                                     no-error .
    put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th rowspan="2" style="text-align: left;">' + buf_clients.obj-name + '</th>' skip
      '         <th rowspan="2" style="text-align: left;">' + string(buf_tt-goods.gds-code) + '</th>' skip
      '         <th rowspan="2" style="text-align: left;">' + buf_tt-goods.gds-name + '</th>' skip
      '         <th style="text-align: left;">гр.упк.</th>' skip
      '         <th rowspan="2" style="text-align: center;">' + (if available (buf_gds-obj) then string(buf_gds-obj.free-qnty) else "0") + '</th>' skip
      '         <th style="text-align: center;">' + string(buf_tt-goods.ok-grp-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(buf_tt-goods.err-grp-marks) + '</th>' skip
      '         <th rowspan="2" style="text-align: center;">' + string(buf_tt-goods.tech-marks) + '</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th style="text-align: left;">инд.упк.</th>' skip
      '         <th style="text-align: center;">' + string(buf_tt-goods.ok-unit-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(buf_tt-goods.err-unit-marks) + '</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */
    
    assign
      obj-free-qnty       = obj-free-qnty + (if available (buf_gds-obj) then buf_gds-obj.free-qnty else 0)
      obj-ok-grp-marks    = obj-ok-grp-marks + buf_tt-goods.ok-grp-marks
      obj-ok-unit-marks   = obj-ok-unit-marks + buf_tt-goods.ok-unit-mark
      obj-err-grp-marks   = obj-err-grp-marks + buf_tt-goods.err-grp-marks
      obj-err-unit-marks  = obj-err-unit-marks + buf_tt-goods.err-unit-marks
      obj-tech-marks      = obj-tech-marks + buf_tt-goods.tech-marks  
    . 
    
    if last-of(buf_tt-goods.obj-code)
    or last-of(buf_tt-goods.obj-code)
    then do :
      put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th rowspan="2" colspan="3" style="text-align: left;">Итого по объекту:</th>' skip
      '         <th style="text-align: left;">гр.упк.</th>' skip
      '         <th rowspan="2" style="text-align: center;">' + string(obj-free-qnty) + '</th>' skip
      '         <th style="text-align: center;">' + string(obj-ok-grp-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(obj-err-grp-marks) + '</th>' skip
      '         <th rowspan="2" style="text-align: center;">' + string(obj-tech-marks) + '</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th style="text-align: left;">инд.упк.</th>' skip
      '         <th style="text-align: center;">' + string(obj-ok-unit-marks) + '</th>' skip
      '         <th style="text-align: center;">' + string(obj-err-unit-marks) + '</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */
    end .
  end . /* for each tt-goods */
  put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
 . /* Точка для закрытия Put */
  output stream OutStr-html close.
  
  run waitfram-hide in this-procedure .
  
  run prn-lib-reportviewer-report-name in this-procedure (
  input THIS-PROCEDURE
  ,input v-file-name-rep-htm
  ).
  
  
end procedure .

procedure get-full-path-RepViewer:
/* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.

procedure define-full-path-Report:
/* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

procedure search-full-path-Report:
/* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
        do:
            message "Не найден файл отчёта: " p-file-name view-as alert-box error.
        end.
    else
        do:
            p-file-name = search(p-file-name).
        end.

end procedure.

procedure Report-Viewer:
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

os-command no-wait value(p-full-path-RepView + " " + search(p-file-name-rep-htm)).

end procedure.

procedure create-file:
/* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

             