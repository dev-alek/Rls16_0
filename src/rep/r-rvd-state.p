block-level on error undo, throw.
/*

$Revision: 7182fdaa4b72, 2879, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:11 2021 +0300 $
$Workfile: r-RVD-state.p $
$Archive: rep/r-RVD-state.p $

Запускалка отчета r-rvd-state.p

Автор: Сливенко СА
Дата создания: 01/04/21


*/
define input parameter p-rep-type as integer no-undo .
define input parameter p-dens as logical no-undo .
define input parameter p-level as logical no-undo .
define input parameter p-temp as logical no-undo .
define input parameter p-rvd-off as logical no-undo .
define input parameter p-rvd-on as logical no-undo .
define input parameter p-rvd-reason-list as character no-undo .


define variable vss-revision    as character no-undo initial "$Revision: 7182fdaa4b72, 2879, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: Пн ноя 22 19:49:11 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-RVD-state.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-RVD-state.p $":U .
define variable vss-description as character no-undo initial "Запускалка отчета r-rvd-state.p":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/prn-lib.i "new shared" }
{ cmp/r-page1.i  }
{ ref/extclass.i }
{ gbl/waitfram.i }
{ rep/html-conv.i }
{ str/placelib.i }

define variable is-petrol   as logical   no-undo.
define variable is-pieces   as logical   no-undo.

define variable store-name as character no-undo.
define variable v-count as integer initial 0  no-undo .

define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num        as integer   no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name       as character no-undo.         /* Наименование отчёта */
    
define variable v-azk-list          as character no-undo .
define variable v-org-list          as character no-undo .
define variable v-legend1           as character no-undo .
define variable v-legend2           as character no-undo .
define variable v-legend3           as character no-undo .
define variable v-legend4           as character no-undo .

define stream OutStr-html.

define buffer bf-gds-list for gds-list .
define buffer buf_clients for ub.clients .
define buffer buf_goods for ub.goods .
define buffer buf_units for ub.units  .
define BUFFER bf_c-user-log for ub.c-user-log .

define temp-table tt-report no-undo
  field firm-name     as character
  field obj-type      as character
  field obj-code      as integer
  field host-code     as integer
  field obj-name      as character
  field pl-code       as integer
  field loc1          as character
  field pl-name       as character
  field gds-code      as integer
  field gds-name      as character
  field corr-dt       as character
  field corr-date     as date
  field corr-time     as int64
  field rvd-reason    as character
  field rvd-reason-code as character
  field pl-state      as character
  field corr-period   as character
  field shift-num     as character
  field ITSM-num      as character
  field executor      as character
  field initiator     as character
  field rvd-par       as character
  field rvd-dens      as logical
  field rvd-level     as logical
  field rvd-temp      as logical
  field is-copy       as logical
.

&scop display-message run write-to-log in this-procedure ( input ~{&my-message~}).

if not can-find( first obj-list ) then do:
  message "Вы не выбрали объект." view-as alert-box error.
  return.
end.

find first obj-list.

if not can-find( first gds-list )
then do:
  for each buf_units no-lock where
        lookup( {&petrolium}, buf_units.type) > 0,
    each buf_goods no-lock where
          buf_goods.unit-base = buf_units.unit-name
          :
    create gds-list.
    buffer-copy buf_goods to  gds-list .
  end.
end.


find first gds-list.

for each bf-gds-list :
  find first ub.goods no-lock where
              ub.goods.artic     = bf-gds-list.artic     and
              ub.goods.prod-type = bf-gds-list.prod-type and
              ub.goods.prod-code = bf-gds-list.prod-code no-error.
  if not available ub.goods then do: next. end.
  { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      is-petrol
      is-pieces
      no-error
  }
  if error-status :error
    or is-petrol <> yes
    or is-pieces <> no
  then do:
    message
      substitute("Отчет может быть запущен только для топливного товара") skip
      view-as alert-box error .
    return .
  end.
end. /* for each bf-gds-list */


run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .

v-legend1 = "А – автоматический ввод данных (Если в системе установлен маркер «Измеряется приборами» и РВД по параметрам отключен)" .
v-legend2 = "Р – ручной ввод данных (Если в системе не установлен маркер «Измеряется приборами или в системе установлен маркер «Измеряется приборами», но разрешение РВД установлено для всех трех парамет-ров»)" .
v-legend3 = "ПА – полуавтоматический ввод данных (Если в системе установлен маркер «Измеряется приборами», но разрешение РВД установлено для одного или двух параметров)" .
v-legend4 = "Ограничение: Актуальность данных отчета соответствует дате и времени формирования отчёта." .


case p-rep-type :
  when 1 then run make-rep .
  when 2 then run make-rep-ext .
end case .

run waitfram-hide in this-procedure .

case p-rep-type :
  when 1 then run print-rep .
  when 2 then run print-rep-ext .
end case .

procedure make-rep :
  
  define variable v-RVD-dens  as logical no-undo .
  define variable v-RVD-temp  as logical no-undo .
  define variable v-RVD-level as logical no-undo .
  define variable v-host-code as integer no-undo .
  define variable v-gds-code  as integer no-undo .
  
  define buffer buf_place for ub.place .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_place-attr for ub.place-attr .
  define buffer buf_goods for ub.goods .
  define buffer buf_clients for ub.clients .
  define buffer buf2_clients for ub.clients .
  
  empty temp-table tt-report .
  
  v-org-list = "" .
  v-azk-list = "" .
  
  for each buf_clients no-lock,
  first obj-list no-lock where obj-list.obj-type = buf_clients.obj-type
                           and obj-list.obj-code = buf_clients.obj-code
                           break by buf_clients.host-code
                           :
    if first-of(buf_clients.host-code)
    then do :
      for first buf2_clients no-lock where buf2_clients.obj-type = {&cmp}
                                       and buf2_clients.obj-code = buf_clients.host-code
                                       :
        v-org-list = v-org-list + buf2_clients.obj-name + ", " .
      end .
    end .                         
  end .
  v-org-list = trim(v-org-list, ", ") .
  
  for each obj-list no-lock break by obj-list.obj-code :
    v-azk-list = v-azk-list + obj-list.obj-name + ", " .
    place_ :
    for each buf_place no-lock where buf_place.obj-type = obj-list.obj-type
                                 and buf_place.obj-code = obj-list.obj-code
                                 and buf_place.status_  = ""
                                 :
      for first buf_pl-gds no-lock where buf_pl-gds.obj-type  = buf_place.obj-type
                                     and buf_pl-gds.obj-code  = buf_place.obj-code
                                     and buf_pl-gds.pl-code   = buf_place.pl-code
                                     :
        v-gds-code = buf_pl-gds.gds-code .
        if not can-find( gds-list where gds-list.gds-code = buf_pl-gds.gds-code )
        then next place_ .                               
      end .
      
      for first buf_place-attr no-lock where buf_place-attr.obj-type  = buf_place.obj-type
                                         and buf_place-attr.obj-code  = buf_place.obj-code
                                         and buf_place-attr.pl-code   = buf_place.pl-code
                                         and buf_place-attr.attr-code = {&place-rvd-dnsty}
                                         :
        assign v-RVD-dens = logical(buf_place-attr.attr-value) .
      end .
      for first buf_place-attr no-lock where buf_place-attr.obj-type  = buf_place.obj-type
                                         and buf_place-attr.obj-code  = buf_place.obj-code
                                         and buf_place-attr.pl-code   = buf_place.pl-code
                                         and buf_place-attr.attr-code = {&place-rvd-lvl}
                                         :
        assign v-RVD-level = logical(buf_place-attr.attr-value) .
      end .
      for first buf_place-attr no-lock where buf_place-attr.obj-type  = buf_place.obj-type
                                         and buf_place-attr.obj-code  = buf_place.obj-code
                                         and buf_place-attr.pl-code   = buf_place.pl-code
                                         and buf_place-attr.attr-code = {&place-rvd-tmp}
                                         :
        assign v-RVD-temp = logical(buf_place-attr.attr-value) .
      end .
      
      create tt-report .
      assign
        tt-report.obj-type  = buf_place.obj-type
        tt-report.obj-code  = buf_place.obj-code
        tt-report.pl-code   = buf_place.pl-code
        tt-report.pl-name   = buf_place.pl-name
        tt-report.loc1      = buf_place.loc1
        tt-report.gds-code  = v-gds-code
        tt-report.rvd-dens  = v-RVD-dens
        tt-report.rvd-level = v-RVD-level
        tt-report.rvd-temp  = v-RVD-temp
      .
      
      for first buf_clients no-lock where buf_clients.obj-type = tt-report.obj-type
                                      and buf_clients.obj-code = tt-report.obj-code
                                      :
        assign
          v-host-code = buf_clients.host-code
          tt-report.obj-name = buf_clients.obj-name
          tt-report.host-code = buf_clients.host-code
        .                             
      end .
      
      for first buf_clients no-lock where buf_clients.obj-type = {&cmp}
                                      and buf_clients.obj-code = v-host-code
                                      :
        assign tt-report.firm-name = buf_clients.obj-name .                                
      end .
      
      for first buf_goods no-lock where buf_goods.gds-code = tt-report.gds-code :
        assign tt-report.gds-name = buf_goods.gds-name .
      end .
      
      if (v-RVD-dens
      and v-RVD-level
      and v-RVD-temp)
      or
      (not buf_place.is-meas)
      then do :
        assign tt-report.pl-state = "Р" .
      end .
      else
      if not v-RVD-dens
      and not v-RVD-level
      and not v-RVD-temp
      then do :
        assign tt-report.pl-state = "А" .
      end .
      else
      if v-RVD-dens
      and v-RVD-level
      and not v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Уровень, Плотность)" .
      end .
      else
      if v-RVD-dens
      and not v-RVD-level
      and v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Температура, Плотность)" .
      end .
      else
      if not v-RVD-dens
      and v-RVD-level
      and v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Уровень, Температура)" .
      end .
      else
      if v-RVD-dens
      and not v-RVD-level
      and not v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Плотность)" .
      end .
      else
      if not v-RVD-dens
      and v-RVD-level
      and not v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Уровень)" .
      end .
      else
      if not v-RVD-dens
      and not v-RVD-level
      and v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Температура)" .
      end .
    
    end .
  end .
  
  v-azk-list = trim(v-azk-list, ", ") .
  
  for each tt-report :
    if p-rvd-on
    and not p-rvd-off
    then do :
      if p-dens
      and not tt-report.rvd-dens
      then
        delete tt-report .
      else
      if p-level
      and not tt-report.rvd-level
      then
        delete tt-report .
      else
      if p-temp
      and not tt-report.rvd-temp
      then
        delete tt-report .
    end .
    else
    if p-rvd-off
    and not p-rvd-on
    then do :
      if p-dens
      and tt-report.rvd-dens
      then
        delete tt-report .
      else
      if p-level
      and tt-report.rvd-level
      then
        delete tt-report .
      else
      if p-temp
      and tt-report.rvd-temp
      then
        delete tt-report .
    end .
  end .
  
end procedure .
  
procedure print-rep :
  
  run gbl/getrpnum.p (output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

  run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */
  
  if x-SelectObject = {&obj-firm}
  or x-SelectObject = {&all}
  then do :
    v-azk-list = "ВСЕ" .
  end .
  
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
      '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 500px; padding: 3px; ' + chr(125) skip
      '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
      '      htm' skip
      '      .rotate ' + chr(123) skip
      '        -webkit-transform: rotate(-90deg);' skip
      '        -moz-transform: rotate(-90deg);' skip
      '        -ms-transform: rotate(-90deg);' skip
      '        -o-transform: rotate(-90deg);' skip
      '        transform: rotate(-90deg);' skip

      /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
      '        -webkit-transform-origin: 50% 50%;' skip
      '        -moz-transform-origin: 50% 50%;' skip
      '        -ms-transform-origin: 50% 50%;' skip
      '        -o-transform-origin: 50% 50%;' skip
      '        transform-origin: 50% 50%;' skip

      /* Should be unset in IE9+ I think.*/
      '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
      '          ' + chr(125) skip
      '            th' + ' ' + chr(123) skip
      '            border: 1px black solid;' skip
      '            word-wrap: break-word;' skip
      '          ' + chr(125) skip
      '   </style>' skip
      '  </head>' skip
  .
  
  put stream OutStr-html unformatted
      '<body>' skip
      '<table name="Лист1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
  .
  put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 90px; border: none;"></td>' skip
      '<td style="width: 100px; border: none;"></td>' skip
      '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Стандартный вариант отчёта "Состояние изменения режима ввода данных по резервуарам"</td>' skip
      '<td colspan="9" style="text-align: left;;">' + v-legend1 + '</td>' skip
      '</tr>' skip   
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Организация: ' + v-org-list + '</td>' skip
      '<td colspan="9" style="text-align: left;">' + v-legend2 + '</td>' skip
      '</tr>' skip  
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Выбор Объекта: ' + v-azk-list + '</td>' skip
      '<td colspan="9" style="text-align: left;">' + v-legend3 + '</td>' skip
      '</tr>' skip 
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Дата печати: ' + string(today) + ' Время: ' + string(time, "hh:mm:ss") + '</td>' skip
      '<td colspan="9" style="text-align: left;">' + v-legend4 + '</td>' skip
      '</tr>' skip
      '</thead>' skip
  .
      
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">ПНПО</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование объекта (АЗК/АЗС)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Номер резервуара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование резервуара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование НП в резервуаре</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Текущее состояние РВД/АВД резервуара</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
      '       </tr>' skip
  . /* Точка для закрытия Put */
  
  for each tt-report break by tt-report.host-code
                           by tt-report.obj-code  
                           by tt-report.pl-code
                           :
                             
    put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center;">' + tt-report.firm-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.obj-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.loc1 + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.pl-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.gds-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.pl-state + '</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */                          
  end .
  
  put stream OutStr-html unformatted
      '     </tbody>' skip
      '   </table>' skip
      '  </body>' skip
      ' </html>' skip
      . /* Точка для закрытия Put */
  output stream OutStr-html close.
  
  run prn-lib-reportviewer-report-name in this-procedure (
      input this-procedure
      ,input v-file-name-rep-htm
      ) no-error.
  if error-status:error then
  do:
      message return-value view-as alert-box.
      return .
  end.
  
/*  run prn-lib-reportviewer in this-procedure (*/
/*      input this-procedure                    */
/*      ,input v-file-name-rep-htm              */
/*      ,input "OS:7_32"                        */
/*      ) no-error.                             */
/*  if error-status:error then                  */
/*  do:                                         */
/*      message return-value view-as alert-box. */
/*      return .                                */
/*  end.                                        */
  
end procedure .  

procedure make-rep-ext :
  
  define variable v-shift-num as integer no-undo .
  define variable v-shift-date as date no-undo .
  define variable v-obj-type  as character no-undo .
  define variable v-obj-code  as integer no-undo .
  define variable v-pl-code   as integer no-undo .
  define variable v-rvd-reason-code as character no-undo .
  define variable v-host-code as integer no-undo .
  define variable v-RVD-on    as logical no-undo .
  define variable v-RVD-params as character no-undo .
  define variable v-RVD-dens  as logical no-undo .
  define variable v-RVD-temp  as logical no-undo .
  define variable v-RVD-level as logical no-undo .
  define variable v-date1 as date no-undo .
  define variable v-date2 as date no-undo .
  define variable v-date-diff as integer no-undo .
  define variable v-time1 as integer no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-time-diff as integer no-undo .
  define variable v-gds-code  as integer no-undo .
  
  define variable v-found-next as logical no-undo .
  
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_ext-classif for ub.ext-classif .
  define buffer buf_place for ub.place .
  define buffer buf_place-attr for ub.place-attr .
  define buffer buf_goods for ub.goods .
  define buffer buf_user-account for ub.user-account .
  define buffer buf_c-user-log for ub.c-user-log .
  define buffer buf_tt-report for tt-report .
  define buffer buf_clients for ub.clients .
  define buffer buf2_clients for ub.clients .
  
  empty temp-table tt-report .
  
  v-date2 = today .
  v-time2 = time .
  
  v-org-list = "" .
  v-azk-list = "" .
  
  for each buf_clients no-lock,
  first obj-list no-lock where obj-list.obj-type = buf_clients.obj-type
                           and obj-list.obj-code = buf_clients.obj-code
                           break by buf_clients.host-code
                           :
    if first-of(buf_clients.host-code)
    then do :
      for first buf2_clients no-lock where buf2_clients.obj-type = {&cmp}
                                       and buf2_clients.obj-code = buf_clients.host-code
                                       :
        v-org-list = v-org-list + buf2_clients.obj-name + ", " .
      end .
    end .                         
  end .
  v-org-list = trim(v-org-list, ", ") .
  
  for each obj-list no-lock break by obj-list.obj-code :
    v-azk-list = v-azk-list + obj-list.obj-name + ", " .
    place_ :
    for each buf_place no-lock where buf_place.obj-type = obj-list.obj-type
                                 and buf_place.obj-code = obj-list.obj-code
                                 and buf_place.status_  = ""
                                 :
      for first buf_pl-gds no-lock where buf_pl-gds.obj-type  = buf_place.obj-type
                                     and buf_pl-gds.obj-code  = buf_place.obj-code
                                     and buf_pl-gds.pl-code   = buf_place.pl-code
                                     :
        v-gds-code = buf_pl-gds.gds-code .
        if not can-find( gds-list where gds-list.gds-code = buf_pl-gds.gds-code )
        then next place_ .                               
      end .
      
      for first buf_place-attr no-lock where buf_place-attr.obj-type  = buf_place.obj-type
                                         and buf_place-attr.obj-code  = buf_place.obj-code
                                         and buf_place-attr.pl-code   = buf_place.pl-code
                                         and buf_place-attr.attr-code = {&place-rvd-dnsty}
                                         :
        assign v-RVD-dens = logical(buf_place-attr.attr-value) .
      end .
      for first buf_place-attr no-lock where buf_place-attr.obj-type  = buf_place.obj-type
                                         and buf_place-attr.obj-code  = buf_place.obj-code
                                         and buf_place-attr.pl-code   = buf_place.pl-code
                                         and buf_place-attr.attr-code = {&place-rvd-lvl}
                                         :
        assign v-RVD-level = logical(buf_place-attr.attr-value) .
      end .
      for first buf_place-attr no-lock where buf_place-attr.obj-type  = buf_place.obj-type
                                         and buf_place-attr.obj-code  = buf_place.obj-code
                                         and buf_place-attr.pl-code   = buf_place.pl-code
                                         and buf_place-attr.attr-code = {&place-rvd-tmp}
                                         :
        assign v-RVD-temp = logical(buf_place-attr.attr-value) .
      end .
      
      create tt-report .
      assign
        tt-report.obj-type  = buf_place.obj-type
        tt-report.obj-code  = buf_place.obj-code
        tt-report.pl-code   = buf_place.pl-code
        tt-report.pl-name   = buf_place.pl-name
        tt-report.loc1      = buf_place.loc1
        tt-report.gds-code  = v-gds-code
        tt-report.rvd-dens  = v-RVD-dens
        tt-report.rvd-level = v-RVD-level
        tt-report.rvd-temp  = v-RVD-temp
      .
      
      for first buf_clients no-lock where buf_clients.obj-type = tt-report.obj-type
                                      and buf_clients.obj-code = tt-report.obj-code
                                      :
        assign
          v-host-code = buf_clients.host-code
          tt-report.obj-name = buf_clients.obj-name
          tt-report.host-code = buf_clients.host-code
        .                             
      end .
      
      for first buf_clients no-lock where buf_clients.obj-type = {&cmp}
                                      and buf_clients.obj-code = v-host-code
                                      :
        assign tt-report.firm-name = buf_clients.obj-name .                                
      end .
      
      for first buf_goods no-lock where buf_goods.gds-code = tt-report.gds-code :
        assign tt-report.gds-name = buf_goods.gds-name .
      end .
      
      if (v-RVD-dens
      and v-RVD-level
      and v-RVD-temp)
      or
      (not buf_place.is-meas)
      then do :
        assign tt-report.pl-state = "Р" .
      end .
      else
      if not v-RVD-dens
      and not v-RVD-level
      and not v-RVD-temp
      then do :
        assign tt-report.pl-state = "А" .
      end .
      else
      if v-RVD-dens
      and v-RVD-level
      and not v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Уровень, Плотность)" .
      end .
      else
      if v-RVD-dens
      and not v-RVD-level
      and v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Температура, Плотность)" .
      end .
      else
      if not v-RVD-dens
      and v-RVD-level
      and v-RVD-temp
      then do :
        assign tt-report.pl-state = "ПА(Уровень, Температура)" .
      end .
      else
      if v-RVD-dens
      and not v-RVD-level
      and not v-RVD-temp
      then do :
        assign
          tt-report.pl-state = "ПА(Плотность)"
          tt-report.rvd-par = "Плотность"
        .
      end .
      else
      if not v-RVD-dens
      and v-RVD-level
      and not v-RVD-temp
      then do :
        assign
          tt-report.pl-state = "ПА(Уровень)"
          tt-report.rvd-par = "Уровень"
        .
      end .
      else
      if not v-RVD-dens
      and not v-RVD-level
      and v-RVD-temp
      then do :
        assign
          tt-report.pl-state = "ПА(Температура)"
          tt-report.rvd-par = "Температура"
        .
      end .
    end . /* place */
  end . /* obj-list */
  
  v-azk-list = trim(v-azk-list, ", ") .
  
  for each tt-report where tt-report.pl-state = "ПА(Уровень, Плотность)"
                        or tt-report.pl-state = "ПА(Температура, Плотность)"
                        or tt-report.pl-state = "ПА(Уровень, Температура)"
                        :
    if tt-report.is-copy 
    then next .
    
    create buf_tt-report .
    buffer-copy tt-report to buf_tt-report . 
    case tt-report.pl-state :
      when "ПА(Уровень, Плотность)"
      then do :
        tt-report.rvd-par = "Уровень" .
        buf_tt-report.rvd-par = "Плотность" .
      end .
      when "ПА(Температура, Плотность)"
      then do :
        tt-report.rvd-par = "Температура" .
        buf_tt-report.rvd-par = "Плотность" .
      end .
      when "ПА(Уровень, Температура)"
      then do :
        tt-report.rvd-par = "Уровень" .
        buf_tt-report.rvd-par = "Температура" .
      end .
    end case .
    tt-report.is-copy = yes .
    buf_tt-report.is-copy = yes .
  end . 
  
  for each tt-report :
       
    user-log_ :
    for each bf_c-user-log no-lock where bf_c-user-log.head-table = 'rvd-reasons':U
                                   break by bf_c-user-log.corr-date desc by bf_c-user-log.corr-time desc
                                   :
      if num-entries(bf_c-user-log.head-table-key, {&delim-cmd}) = 23 /* Установка РВД в СВЕРКЕ */   
      then next user-log_ .         
                        
      v-shift-date = date(entry(3, bf_c-user-log.head-table-key, {&delim-cmd})) .
      v-shift-num = integer(entry(4, bf_c-user-log.head-table-key, {&delim-cmd})) .
      v-obj-type = entry(1, bf_c-user-log.head-table-key, {&delim-cmd}) .
      v-obj-code = integer(entry(2, bf_c-user-log.head-table-key, {&delim-cmd})) . 
      if not (v-obj-type = tt-report.obj-type and v-obj-code = tt-report.obj-code) then next user-log_ .   
      
      v-pl-code = integer(entry(5, bf_c-user-log.head-table-key, {&delim-cmd})) .
      if not (v-pl-code = tt-report.pl-code) then next user-log_ .
      
      v-RVD-params = entry(6, bf_c-user-log.head-table-key, {&delim-cmd}) .
      if tt-report.rvd-par = "Уровень"
      and not can-do(v-RVD-params, 'l')
      then next user-log_ .
      if tt-report.rvd-par = "Температура"
      and not can-do(v-RVD-params, 'T')
      then next user-log_ .
      if tt-report.rvd-par = "Плотность"
      and not can-do(v-RVD-params, 'p')
      then next user-log_ .
      
      v-rvd-reason-code = entry(8, bf_c-user-log.head-table-key, {&delim-cmd}) .
      find first buf_ext-classif no-lock where buf_ext-classif.CharKey_One = v-rvd-reason-code
                                           and buf_ext-classif.classif-subject = {&extclass_rvd-reason} 
                                           and buf_ext-classif.classif-name = {&extclass_rvd-reason}
                                           no-error .
      if not available buf_ext-classif
      then next user-log_ .
        
      for first buf_user-account no-lock where buf_user-account.user-id = bf_c-user-log.corr-user-name :
        assign tt-report.executor = buf_user-account.nik .
      end .
      
      assign
        tt-report.rvd-reason  = buf_ext-classif.CharKey_Two
        tt-report.rvd-reason-code = entry(8, bf_c-user-log.head-table-key, {&delim-cmd})
        tt-report.corr-date   = bf_c-user-log.corr-date
        tt-report.corr-time   = bf_c-user-log.corr-time
        tt-report.corr-dt     = string(bf_c-user-log.corr-date, "99.99.9999") + " " + string(bf_c-user-log.corr-time, "hh:mm")
        tt-report.corr-dt     = replace(tt-report.corr-dt, ":", "-")
        tt-report.shift-num   = string(v-shift-num)
        tt-report.ITSM-num    = entry(9, bf_c-user-log.head-table-key, {&delim-cmd})
        tt-report.initiator   = entry(10, bf_c-user-log.head-table-key, {&delim-cmd})
      .
      
      v-date1 = bf_c-user-log.corr-date .
      v-time1 = bf_c-user-log.corr-time .

      
      v-date-diff = v-date2 - v-date1 .
      v-time-diff = v-time2 - v-time1 .
      if v-time-diff < 0
      then do :
        v-date-diff = v-date-diff - 1 .
        v-time-diff = v-time-diff + 86400 .
      end .
      
      assign tt-report.corr-period = string(v-date-diff) + "д. " + string(v-time-diff, "hh:mm:ss") .
            
      leave user-log_ .                       
    end . /* user-log_ */
  end . /* tt-report */
  
  for each tt-report :
    if p-rvd-on
    and not p-rvd-off
    then do :
      if p-dens
      and not tt-report.rvd-dens
      then
        delete tt-report .
      else
      if p-level
      and not tt-report.rvd-level
      then
        delete tt-report .
      else
      if p-temp
      and not tt-report.rvd-temp
      then
        delete tt-report .
    end .
    else
    if p-rvd-off
    and not p-rvd-on
    then do :
      if p-dens
      and tt-report.rvd-dens
      then
        delete tt-report .
      else
      if p-level
      and tt-report.rvd-level
      then
        delete tt-report .
      else
      if p-temp
      and tt-report.rvd-temp
      then
        delete tt-report .
    end .
  end . /* tt-report */
  
  if p-rvd-reason-list > ""
  then do :
    for each tt-report :
      if not can-do(p-rvd-reason-list, tt-report.rvd-reason-code)
      then
        delete tt-report .
    end .
  end .
  
end procedure .

procedure print-rep-ext :
  
  run gbl/getrpnum.p (output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

  run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */
  
  if x-SelectObject = {&obj-firm}
  or x-SelectObject = {&all}
  then do :
    v-azk-list = "ВСЕ" .
  end .
  
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
      '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 500px; padding: 3px; ' + chr(125) skip
      '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
      '      htm' skip
      '      .rotate ' + chr(123) skip
      '        -webkit-transform: rotate(-90deg);' skip
      '        -moz-transform: rotate(-90deg);' skip
      '        -ms-transform: rotate(-90deg);' skip
      '        -o-transform: rotate(-90deg);' skip
      '        transform: rotate(-90deg);' skip

      /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
      '        -webkit-transform-origin: 50% 50%;' skip
      '        -moz-transform-origin: 50% 50%;' skip
      '        -ms-transform-origin: 50% 50%;' skip
      '        -o-transform-origin: 50% 50%;' skip
      '        transform-origin: 50% 50%;' skip

      /* Should be unset in IE9+ I think.*/
      '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
      '          ' + chr(125) skip
      '            th' + ' ' + chr(123) skip
      '            border: 1px black solid;' skip
      '            word-wrap: break-word;' skip
      '          ' + chr(125) skip
      '   </style>' skip
      '  </head>' skip
  .
  
  put stream OutStr-html unformatted
      '<body>' skip
      '<table name="Лист1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
  .
  put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 90px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 90px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 85px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="14" style="text-align: left; font-weight:bold;"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Развернутый вариант отчёта "Состояние изменения режима ввода данных по резервуарам"</td>' skip
      '<td colspan="9" style="text-align: left;;">' + v-legend1 + '</td>' skip
      '</tr>' skip   
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Организация: ' + v-org-list + '</td>' skip
      '<td colspan="9" style="text-align: left;">' + v-legend2 + '</td>' skip
      '</tr>' skip  
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Выбор Объекта: ' + v-azk-list + '</td>' skip
      '<td colspan="9" style="text-align: left;">' + v-legend3 + '</td>' skip
      '</tr>' skip 
      '<tr>' skip
      '<td colspan="5" style="text-align: left; font-weight:bold;">Дата и время формирования отчёта: ' + string(today) + ', ' + string(time, "hh:mm:ss") + '</td>' skip
      '<td colspan="9" style="text-align: left;">' + v-legend4 + '</td>' skip
      '</tr>' skip
      '</thead>' skip
  .
      
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">ПНПО</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование объекта (АЗК/АЗС)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Номер резервуара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование резервуара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование НП в резервуаре</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата/время изменения режима</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Длительность состояния по резервуару</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Текущее состояние РВД/АВД резервуара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Параметр для РВД</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Причина перевода на РВД</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Смена</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Номер заявки ITSM</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Исполнитель заявки</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Инициатор заявки</th>' skip
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
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">9</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">10</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">11</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">12</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">13</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">14</th>' skip
      '       </tr>' skip
  . /* Точка для закрытия Put */    

  for each tt-report break by tt-report.host-code 
                           by tt-report.obj-code  
/*                           by tt-report.pl-code*/
                           by tt-report.corr-date 
                           by tt-report.corr-time 
                           :
                             
    put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center;">' + tt-report.firm-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.obj-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.loc1 + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.pl-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.gds-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.corr-dt + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.corr-period + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.pl-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.rvd-par + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.rvd-reason + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.shift-num + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.ITSM-num + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.executor + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.initiator + '</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */                          
  end .
  
  put stream OutStr-html unformatted
      '     </tbody>' skip
      '   </table>' skip
      '  </body>' skip
      ' </html>' skip
      . /* Точка для закрытия Put */
  output stream OutStr-html close.
  
  run prn-lib-reportviewer-report-name in this-procedure (
      input this-procedure
      ,input v-file-name-rep-htm
      ) no-error.
  if error-status:error then
  do:
      message return-value view-as alert-box.
      return .
  end.

/*  run prn-lib-reportviewer in this-procedure (*/
/*      input this-procedure                    */
/*      ,input v-file-name-rep-htm              */
/*      ,input "OS:7_32"                        */
/*      ) no-error.                             */
/*  if error-status:error then                  */
/*  do:                                         */
/*      message return-value view-as alert-box. */
/*      return .                                */
/*  end.                                        */
  
end procedure .

procedure define-full-path-Report:
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

procedure create-file:
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

PROCEDURE write-to-log :
define input param p-str as char no-undo.

do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.

end. /* do on error */
END PROCEDURE.