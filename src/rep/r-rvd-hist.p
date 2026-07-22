block-level on error undo, throw.
/*

$Revision: 05d5ec57b83c, 3284, rls $
$Author: SSlivenko $
$Date: 2023/03/29 08:47:58 $
$Workfile: r-RVD-hist.p $
$Archive: rep/r-RVD-hist.p $

Запускалка отчета r-ctrlsh.p

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/12/10
Author: Dmitry Ukhanov
Creation date: 11/12/10

*/
define input parameter p-inv-RVD as logical no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 05d5ec57b83c, 3284, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/03/29 08:47:58 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-RVD-hist.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-RVD-hist.p $":U .
define variable vss-description as character no-undo initial "Запускалка отчета r-inptl.p":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/prn-lib.i "new shared" }
{ cmp/r-page1.i  }
{ ref/extclass.i }
{ gbl/waitfram.i }
{ rep/html-conv.i }

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
define variable v-period            as character no-undo .
define variable v-legend1           as character no-undo .
define variable v-legend2           as character no-undo .
define variable v-legend3           as character no-undo .

define variable x-Time-Start        as integer   no-undo init -1 .
define variable x-Time-End          as integer   no-undo init -1 .

define stream OutStr-html.

define buffer bf-gds-list for gds-list .
define buffer buf_clients for ub.clients .
define buffer buf_goods for ub.goods .
define buffer buf_units for ub.units  .
define buffer buf_shift-obj for ub.shift-obj .
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
  field corr-par      as character
  field rvd-reason    as character
  field pl-state      as character
  field corr-period   as character
  field temp-state    as character
  field dens-state    as character
  field level-state   as character
  field shift-num     as character
  field ITSM-num      as character
  field executor      as character
  field initiator     as character
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

if x-TOG-Shift
then do :
  for each obj-list no-lock :
    find last buf_shift-obj no-lock where buf_shift-obj.obj-type = obj-list.obj-type
                                      and buf_shift-obj.obj-code = obj-list.obj-code
                                      and buf_shift-obj.shift-date <= x-Date-End
                                      and buf_shift-obj.shift-num <= x-Shift-End
                                      no-error .
    if available buf_shift-obj
    then do :
      if buf_shift-obj.close-date = ?
      then do :
        x-Date-End = today .
        x-Time-End = time .
      end .
      else do :
        if buf_shift-obj.close-date >= x-Date-End
        then do :
          if (buf_shift-obj.close-date = x-Date-End and buf_shift-obj.close-time > x-Time-End)
          or buf_shift-obj.close-date > x-Date-End
          then x-Time-End = buf_shift-obj.close-time .
          x-Date-End = buf_shift-obj.close-date .
        end .
      end .
    end .  /* buf_shift-obj  */
    find first buf_shift-obj no-lock where buf_shift-obj.obj-type = obj-list.obj-type
                                       and buf_shift-obj.obj-code = obj-list.obj-code
                                       and buf_shift-obj.shift-date = x-Date-Start
                                       and buf_shift-obj.shift-num >= x-Shift-Start
                                       no-error .
    if available buf_shift-obj
    then do :
      if x-Time-Start = -1
      then x-Time-Start = buf_shift-obj.open-time .
      if buf_shift-obj.open-time < x-Time-Start
      then x-Time-Start = buf_shift-obj.open-time .
    end .  /* buf_shift-obj  */
  end .
end .

if x-TOG-Shift
then do :
  v-period = "Смены с " + string(x-Shift-Start) +
             " по " + string(x-Shift-End) + {&new-line} +
             "За период с " + string(x-Date-Start) +
             " по " + string(x-Date-End)
             .
end .
else do :
  v-period = "За период с " + string(x-Date-Start) +
             " по " + string(x-Date-End)
             . 
end .

v-legend1 = "А – автоматический ввод данных; Р – ручной ввод данных; ПА – полуавтоматический ввод данных;" .
v-legend2 = "Расшифровка для столбца 9 - Указывается режим измерения для резервуара после его изменения - А: Если в системе установлен маркер «Измеряется приборами» и РВД по параметрам отключен;   Р: Если в системе не установлен маркер «Измеряется приборами или в системе установлен маркер «Измеряется приборами», но разрешение РВД установлено для всех трех параметров» ПА: Если в системе установлен маркер «Измеряется приборами», но разрешение РВД установлено для одного или двух параметров" .
v-legend3 = "Расшифровка для столбцов 7,11,12,13 - 7: Указывается режим измерения в который переводится параметр/параметры (А или Р); 11,12,13: Указывается режим измерения для параметров после его изменения (А или Р)" .

run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .
run make-rep .
run print-rep .
run waitfram-hide in this-procedure .

procedure make-rep :
  
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
  define variable v-is-meas as logical no-undo .
  
  define variable v-found-next as logical no-undo .
  
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_ext-classif for ub.ext-classif .
  define buffer buf_place for ub.place .
  define buffer buf_goods for ub.goods .
  define buffer buf_user-account for ub.user-account .
  define buffer buf_c-user-log for ub.c-user-log .
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
    v-azk-list = v-azk-list + buf_clients.obj-name + ", " .                    
  end .
  v-org-list = trim(v-org-list, ", ") .
  v-azk-list = trim(v-azk-list, ", ") .
 
  user-log_ :
  for each bf_c-user-log no-lock where bf_c-user-log.corr-date >= x-Date-Start
                                   and bf_c-user-log.corr-date <= x-Date-End
                                   and bf_c-user-log.head-table = 'rvd-reasons':U
                                   break by bf_c-user-log.corr-date by bf_c-user-log.corr-time
                                   :
    if not p-inv-RVD
    and num-entries(bf_c-user-log.head-table-key, {&delim-cmd}) = 23
    and entry(15, bf_c-user-log.head-table-key, {&delim-cmd}) > ""/* Установка РВД в СВЕРКЕ */
    then next user-log_ .
    
    v-obj-type = entry(1, bf_c-user-log.head-table-key, {&delim-cmd}) .
    v-obj-code = integer(entry(2, bf_c-user-log.head-table-key, {&delim-cmd})) .
    if not can-find( first obj-list where obj-list.obj-type = v-obj-type and obj-list.obj-code = v-obj-code )
    then next user-log_ .
    
    v-shift-date = date(entry(3, bf_c-user-log.head-table-key, {&delim-cmd})) .
    v-shift-num = integer(entry(4, bf_c-user-log.head-table-key, {&delim-cmd})) .
    
    if x-TOG-Shift
    then do :  
      if v-shift-num = 0
      then do :
        if v-shift-date < x-Date-Start
        or v-shift-date > x-Date-end
        then next user-log_ .
      end .
      else do : 
        if (v-shift-date = x-Date-Start 
        and v-shift-num < x-Shift-Start)
        or v-shift-date < x-Date-Start
        then next user-log_ .
        if (v-shift-date = x-Date-End 
        and v-shift-num > x-Shift-End)
        or v-shift-date > x-Date-end
        then next user-log_ .
      end .
      if x-Time-End >= 0
      then do :
        if bf_c-user-log.corr-date = x-Date-end
        and bf_c-user-log.corr-time > (x-Time-End + 59)
        then next user-log_ .
      end .
      if x-Time-Start >= 0
      then do :
        if bf_c-user-log.corr-date = x-Date-Start
        and bf_c-user-log.corr-time < x-Time-Start
        then next user-log_ .
      end .
    end .
    
    v-pl-code = integer(entry(5, bf_c-user-log.head-table-key, {&delim-cmd})) . 
    find first buf_pl-gds no-lock where buf_pl-gds.obj-type = v-obj-type
                                    and buf_pl-gds.obj-code = v-obj-code
                                    and buf_pl-gds.pl-code  = v-pl-code
                                    no-error .
    if not available buf_pl-gds
    then next user-log_ .
    
    if not can-find( first gds-list where gds-list.gds-code = buf_pl-gds.gds-code )
    then next user-log_ .
    
    v-rvd-reason-code = entry(8, bf_c-user-log.head-table-key, {&delim-cmd}) .
    find first buf_ext-classif no-lock where buf_ext-classif.CharKey_One = v-rvd-reason-code
                                         and buf_ext-classif.classif-subject = {&extclass_rvd-reason} 
                                         and buf_ext-classif.classif-name = {&extclass_rvd-reason}
                                         no-error .
    if not available buf_ext-classif
    then next user-log_ .
    
    v-RVD-params = entry(6, bf_c-user-log.head-table-key, {&delim-cmd}) .
    v-RVD-on = logical(entry(7, bf_c-user-log.head-table-key, {&delim-cmd})) .
    
    v-RVD-temp = logical(entry(11, bf_c-user-log.head-table-key, {&delim-cmd})) .
    v-RVD-dens = logical(entry(12, bf_c-user-log.head-table-key, {&delim-cmd})) .
    v-RVD-level = logical(entry(13, bf_c-user-log.head-table-key, {&delim-cmd})) .
    
    if num-entries(bf_c-user-log.head-table-key, {&delim-cmd}) > 13
    then
      v-is-meas = logical(entry(14, bf_c-user-log.head-table-key, {&delim-cmd})) .
    
    create tt-report .
    assign
      tt-report.obj-type    = v-obj-type
      tt-report.obj-code    = v-obj-code
      tt-report.pl-code     = v-pl-code
      tt-report.gds-code    = buf_pl-gds.gds-code
      tt-report.rvd-reason  = buf_ext-classif.CharKey_Two
      tt-report.corr-date   = bf_c-user-log.corr-date
      tt-report.corr-time   = bf_c-user-log.corr-time
      tt-report.corr-dt     = string(bf_c-user-log.corr-date, "99.99.9999") + " " + string(bf_c-user-log.corr-time, "hh:mm")
      tt-report.corr-dt     = replace(tt-report.corr-dt, ":", "-")
      tt-report.shift-num   = string(v-shift-num)
      tt-report.ITSM-num    = entry(9, bf_c-user-log.head-table-key, {&delim-cmd})
      tt-report.initiator   = entry(10, bf_c-user-log.head-table-key, {&delim-cmd})
      tt-report.temp-state  = if v-RVD-temp then "Р" else "А"
      tt-report.dens-state  = if v-RVD-dens then "Р" else "А"
      tt-report.level-state = if v-RVD-level then "Р" else "А"
    .
    
    for first buf_user-account no-lock where buf_user-account.user-id = bf_c-user-log.corr-user-name :
      assign tt-report.executor = buf_user-account.nik .
    end .
    
    for first buf_clients no-lock where buf_clients.obj-type = v-obj-type
                                    and buf_clients.obj-code = v-obj-code
                                    :
      assign
        v-host-code = buf_clients.host-code
        tt-report.obj-name = buf_clients.obj-name
        tt-report.host-code = v-host-code
      .                             
    end .
    
    for first buf_clients no-lock where buf_clients.obj-type = {&cmp}
                                    and buf_clients.obj-code = v-host-code
                                    :
      assign tt-report.firm-name = buf_clients.obj-name .                                
    end .
    
    for first buf_place no-lock where buf_place.obj-type = v-obj-type
                                  and buf_place.obj-code = v-obj-code
                                  and buf_place.pl-code  = v-pl-code
                                  :
      assign
        tt-report.pl-name = buf_place.pl-name
        tt-report.loc1    = buf_place.loc1
      .                              
    end .
    
    for first buf_goods no-lock where buf_goods.gds-code = tt-report.gds-code :
      assign tt-report.gds-name = buf_goods.gds-name .
    end .
    
    if can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р" else "А" .
    end .
    else
    if can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and not can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Температура, Плотность)" else "А(Температура, Плотность)" .
    end .
    else
    if can-do(v-RVD-params, 'p')
    and not can-do(v-RVD-params, 'T')
    and not can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Плотность)" else "А(Плотность)" .
    end .
    else
    if can-do(v-RVD-params, 'p')
    and not can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Уровень, Плотность)" else "А(Уровень, Плотность)" .
    end .
    else
    if not can-do(v-RVD-params, 'p')
    and not can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Уровень)" else "А(Уровень)" .
    end .
    else
    if not can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Уровень, Температура)" else "А(Уровень, Температура)" .
    end .
    else
    if not can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and not can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Температура)" else "А(Температура)" .
    end .
    
    if (v-RVD-dens
    and v-RVD-level
    and v-RVD-temp)
    or
    (not v-is-meas)
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
    
    if num-entries(bf_c-user-log.head-table-key, {&delim-cmd}) = 23 
    and entry(15, bf_c-user-log.head-table-key, {&delim-cmd}) > "" /* Установка РВД в СВЕРКЕ */
    then do :
      assign tt-report.corr-period = "0" .
    end .
    else do :
      v-found-next = false .
      v-date1 = bf_c-user-log.corr-date .
      v-time1 = bf_c-user-log.corr-time .
      find-next_ :
      for each buf_c-user-log no-lock where buf_c-user-log.head-table = 'rvd-reasons':U
                                        and (buf_c-user-log.corr-date > bf_c-user-log.corr-date
                                          or (buf_c-user-log.corr-date = bf_c-user-log.corr-date
                                          and buf_c-user-log.corr-time > bf_c-user-log.corr-time))
                                          break by buf_c-user-log.corr-date by buf_c-user-log.corr-time
                                          :
        if num-entries(buf_c-user-log.head-table-key, {&delim-cmd}) = 23
        and entry(15, buf_c-user-log.head-table-key, {&delim-cmd}) > "" /* Установка РВД в СВЕРКЕ */
        then next find-next_ .                                   
        if v-obj-type = entry(1, buf_c-user-log.head-table-key, {&delim-cmd}) 
        and v-obj-code = integer(entry(2, buf_c-user-log.head-table-key, {&delim-cmd}))     
        and v-pl-code = integer(entry(5, buf_c-user-log.head-table-key, {&delim-cmd}))
        then do :
          v-date2 = buf_c-user-log.corr-date .
          v-time2 = buf_c-user-log.corr-time .
          v-found-next = true .
          leave find-next_ .
        end .                              
      end .
      if not v-found-next
      then do :
        v-date2 = today .
        v-time2 = time .
      end .
      v-date-diff = v-date2 - v-date1 .
      v-time-diff = v-time2 - v-time1 .
      if v-time-diff < 0
      then do :
        v-date-diff = v-date-diff - 1 .
        v-time-diff = v-time-diff + 86400 .
      end .
      
      assign tt-report.corr-period = string(v-date-diff) + "д. " + string(v-time-diff, "hh:mm:ss") .
    end .
                               
  end .
  
end procedure .

procedure print-rep :
  
  run gbl/getrpnum.p (output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

  run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */
  
  
  
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
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 85px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 75px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 70px; border: none;"></td>' skip
      '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="17" style="text-align: left; font-weight:bold;"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Отчет "История изменения режима ввода данных по резервуарам"</td>' skip
      '<td colspan="11" style="text-align: left;;">' + v-legend1 + '</td>' skip
      '</tr>' skip   
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Организация: ' + v-org-list + '</td>' skip
      '<td colspan="11" style="text-align: left;">' + v-legend2 + '</td>' skip
      '</tr>' skip  
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Выбор Объекта: ' + v-azk-list + '</td>' skip
      '<td colspan="11" style="text-align: left;">' + v-legend3 + '</td>' skip
      '</tr>' skip 
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">' + v-period + '</td>' skip
      '<td colspan="11" style="text-align: left;"><br></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Дата печати: ' + string(today) + ' Время: ' + string(time, "hh:mm:ss") + '</td>' skip
      '<td colspan="11" style="text-align: left;"><br></td>' skip
      '</tr>' skip
      '</thead>' skip
  .
      
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">ПНПО</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Наименование объекта (АЗК/АЗС)</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Номер резервуара</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Наименование резервуара</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Наименование НП в резервуаре на момент изменения режима</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Дата/время изменения режима</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Изменяемый параметр</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Причина перевода на РВД</th>' skip
      '         <th colspan="5" style="text-align: center; font-weight:bold; background-color: silver;">Состояние резервуара после изменения режима</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Смена</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Номер заявки ITSM/Номер приказа о проведении инвентаризации</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Исполнитель заявки</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Инициатор заявки/Сотрудник Инв. Комиссии</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Резервуар</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Длительность состояния по резервуару</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Температура</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Плотность</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Уровень</th>' skip
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
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">15</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">16</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">17</th>' skip
      '       </tr>' skip
  . /* Точка для закрытия Put */    

  for each tt-report break by tt-report.host-code
                           by tt-report.obj-code  
                           by tt-report.pl-code
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
      '         <th style="text-align: center;">' + tt-report.corr-par + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.rvd-reason + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.pl-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.corr-period + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.temp-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.dens-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.level-state + '</th>' skip
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