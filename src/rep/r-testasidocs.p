block-level on error undo, throw.
/*

$Revision$
$Author$ SSlivenko
$Date$
$Workfile$
$Archive$

Результат проверки корректности работы АСИ в резервуаре

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-test-asi-type as character   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Результат проверки корректности работы АСИ в резервуаре".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i      }
{ cmp/r-pril.i   }
{ ref/cp-attr.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/w-rep.i    }
{ rep/fmtcli.i   }
{ rep/torgconf.i }

{ gbl/paramls.i  }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }

/* Temp-Table and Buffer definitions                                    */
                  
define stream OutStr-html.

DEFINE TEMP-TABLE tt-result
  field num                     as integer                /*col1 Номер П/П */
  field obj-type                as character             
  field obj-code                as integer
  field obj-name                as character              /*col2  АЗК/АЗС  */
  field shift-date              like rvs-doc.shift-date   /*col3  Дата смены */
  field shift-num               like rvs-doc.shift-num    /*col4  Номер смены  */
  field rvs-code                as character              /*col5  Номер документа проверки  */
  field doc-date                as date                   /*col6  Дата документа проверки */
  field gds-code                as integer
  field gds-name                as character              /*col7  Марка НП  */
  field pl-code                 as integer
  field loc1                    as character              /*col8  Номер резервура  */
  /*  Фактические замеры комиссии  */
  field state-level-total       as decimal    /*col9  Уровень по метроштоку, см  */
  field izmer-density           as decimal    /*col10 Плотность по замерам, г/см3 */
  field pomi-density            as decimal    /*col11 Плотность, приведенная к стандартной температуре, г/см3  */
  field state-temperature       as decimal    /*col12 Температура, С  */
  field state-mass              as decimal    /*col13 Масса, кг  */
  /*  Данные замеров АСИ в резервуаре  */
  field level-total             as decimal    /*col14 Уровень, см  */
  field density                 as decimal    /*col15 Плотность по уровнемеру, г/см3  */
  field asi-pomi-density        as decimal    /*col16 Плотность с АСИ, приведенная к стандартной температуре, г/см3  */
  field temperature             as decimal    /*col17 Температура, С  */
  field mass                    as decimal    /*col18 Масса, кг  */
  /*  Результат расчета проверки  */
  field diff-density-gram       as decimal    /*col19 Расхождение значения по плотности НП (г/cм3)  */
  field diff-density            as decimal    /*col20 Расхождение значения по плотности НП (кг/м3)  */
  field diff-mass-kilo          as decimal    /*col21 Расхождение по массе  (кг)  */
  field diff-mass               as decimal    /*col22 Расхождение в % по массе  */
  
  field test-asi-type           as character
  field asi-type-name           as character  /*col23 Тип проверки  */
  
  index pi 
    obj-type obj-code rvs-code gds-code pl-code
. 

function fDec2Str returns character
   (input idec as decimal,
    input iformat as char):
   define variable vdecstr as character no-undo.
   if idec = ? then
      vdecstr = "".
   else
      vdecstr = trim(string(idec, iformat)).

   return vdecstr.
end function.

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-period            as character no-undo .
define variable v-list-obj          as character no-undo .
define variable v-print-date        as character no-undo .
define variable ii                  as integer   no-undo .

define buffer buf_rvs-doc       for ub.rvs-doc .
define buffer buf_doc-attr      for ub.doc-attr .
define buffer buf_rvs-line      for ub.rvs-line .
define buffer buf_rvs-line-attr for ub.rvs-line-attr .
define buffer buf_goods         for ub.goods .
define buffer buf_place         for ub.place .

do
on error undo, return error return-value
:

  find first obj-list no-error .
  if not available obj-list then 
  do:
    message
      "Не указан объект для формирования отчета!"
      view-as alert-box error.
    undo, return error.
  end.
  

  /*Данные для шапки*/
  /*Период*/
  if x-TOG-Shift then 
  do:
    v-period = "Смены с " + string (x-Shift-Start) + " по " + string (x-Shift-End) + " За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.
  else 
  do:
    v-period = "За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.      
  /*Дата и время печати*/
  DEFINE VARIABLE v-today as date    no-undo .
  DEFINE VARIABLE v-time  as integer no-undo .
  run cur-time in this-procedure (
    output v-today
    , output v-time
    ).
  v-print-date = "Дата печати: " + string (v-today,"99.99.9999") + ", время: " + string(truncate (v-time / 3600, 0)) + ":" + string((v-time modulo 3600) / 60,"99")  + ":" + string((v-time modulo 3600) / 360,"99").     

  assign ii = 0 .
  empty temp-table tt-result .

  for each obj-list no-lock:
    if v-list-obj = "" then v-list-obj = string(obj-list.obj-name).
    else v-list-obj = v-list-obj + ", " + string(obj-list.obj-name).
  
    if x-TOG-Shift
    then do:
      for each buf_rvs-doc no-lock where buf_rvs-doc.obj-type   = obj-list.obj-type
                                     and buf_rvs-doc.obj-code   = obj-list.obj-code
                                     and buf_rvs-doc.rvs-type   = {&test-asi}
                                     and buf_rvs-doc.status_    = {&fact}
                                     and (buf_rvs-doc.shift-date > X-date-Start or (buf_rvs-doc.shift-date = X-date-Start and buf_rvs-doc.shift-num >= x-Shift-Start))
                                     and (buf_rvs-doc.shift-date < X-date-End or (buf_rvs-doc.shift-date = X-date-End and buf_rvs-doc.shift-num <= x-Shift-End))
      :
        run fill-tt .
      end .
    end.
    else do:
      for each buf_rvs-doc no-lock where buf_rvs-doc.obj-type   = obj-list.obj-type
                                     and buf_rvs-doc.obj-code   = obj-list.obj-code
                                     and buf_rvs-doc.rvs-type   = {&test-asi}
                                     and buf_rvs-doc.status_    = {&fact}
                                     and buf_rvs-doc.fact-date >= X-date-Start
                                     and buf_rvs-doc.fact-date <= X-date-End
      :
        run fill-tt .
      end .
    end.  
  end.

   
  /*печать*/
  run print-report .
  
    
end .

procedure fill-tt :
  define variable v-test-asi-type    as character no-undo .
  define variable v-izmer-density    as decimal no-undo .
  define variable v-pomi-density     as decimal no-undo .
  define variable v-temp-izm-vol     as decimal no-undo .
  define variable v-asi-pomi-density as decimal no-undo .
  define variable v-diff             as decimal no-undo .
  
  for first buf_doc-attr no-lock where buf_doc-attr.doc-code  = buf_rvs-doc.rvs-code
                                   and buf_doc-attr.attr-code = "test-asi-type"
  :
    v-test-asi-type = buf_doc-attr.attr-value .
  end .
  
  if p-test-asi-type <> "all"
  and p-test-asi-type <> v-test-asi-type
  then do :
    return .
  end .
  
  for each buf_rvs-line no-lock where buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                  and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                  and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code,
    first buf_goods no-lock where buf_goods.gds-code = buf_rvs-line.gds-code,
    first buf_place no-lock where buf_place.obj-type = buf_rvs-line.obj-type
                              and buf_place.obj-code = buf_rvs-line.obj-code
                              and buf_place.pl-code  = buf_rvs-line.pl-code
  :
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "izmer-density"
    :
      assign v-izmer-density = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "pomi-density"
    :
      assign v-pomi-density = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "asi-pomi-density"
    :
      assign v-asi-pomi-density = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "test-asi-diff"
    :
      assign v-diff = decimal(buf_rvs-line-attr.attr-value) .
    end .
    for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                                          and buf_rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                                          and buf_rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                                          and buf_rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                                          and buf_rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                                          and buf_rvs-line-attr.attr-code = "temp-izm-vol"
    :
      assign v-temp-izm-vol = decimal(buf_rvs-line-attr.attr-value) .
    end .
    
    create tt-result .
    assign
      ii = ii + 1
      tt-result.num               = ii
      tt-result.obj-type          = buf_rvs-doc.obj-type
      tt-result.obj-code          = buf_rvs-doc.obj-code
      tt-result.obj-name          = obj-list.obj-name
      tt-result.shift-date        = buf_rvs-doc.shift-date
      tt-result.shift-num         = buf_rvs-doc.shift-num
      tt-result.rvs-code          = buf_rvs-doc.rvs-code
      tt-result.doc-date          = buf_rvs-doc.doc-date
      tt-result.gds-code          = buf_goods.gds-code
      tt-result.gds-name          = buf_goods.gds-name
      tt-result.pl-code           = buf_place.pl-code
      tt-result.loc1              = buf_place.loc1
      tt-result.test-asi-type     = v-test-asi-type
    .
    case v-test-asi-type :
      when "test-asi_dens-place"
      then do :
        assign
          tt-result.state-level-total = ?
          tt-result.izmer-density     = v-izmer-density
          tt-result.pomi-density      = ?
          tt-result.state-temperature = ?
          tt-result.state-mass        = ?
          
          tt-result.level-total       = ?
          tt-result.density           = buf_rvs-line.density
          tt-result.asi-pomi-density  = ?
          tt-result.temperature       = ?
          tt-result.mass              = ?
          
          tt-result.diff-density-gram = v-diff / 1000
          tt-result.diff-density      = v-diff
          tt-result.diff-mass-kilo    = ?
          tt-result.diff-mass         = ?
                           
          tt-result.asi-type-name     = "Резервуар"
        .
      end .
      when "test-asi_dens-pump"
      then do :
        assign
          tt-result.state-level-total = ?
          tt-result.izmer-density     = v-izmer-density
          tt-result.pomi-density      = v-pomi-density
          tt-result.state-temperature = v-temp-izm-vol
          tt-result.state-mass        = ?
          
          tt-result.level-total       = ?
          tt-result.density           = buf_rvs-line.density
          tt-result.asi-pomi-density  = v-asi-pomi-density
          tt-result.temperature       = buf_rvs-line.temperature
          tt-result.mass              = ?
          
          tt-result.diff-density-gram = v-diff / 1000
          tt-result.diff-density      = v-diff
          tt-result.diff-mass-kilo    = ?
          tt-result.diff-mass         = ?
          
          tt-result.asi-type-name     = "ТРК"
        .
      end .
      when "test-asi_mass"
      then do :
        assign
          tt-result.state-level-total = buf_rvs-line.state-level-total
          tt-result.izmer-density     = v-izmer-density
          tt-result.pomi-density      = v-pomi-density
          tt-result.state-temperature = v-temp-izm-vol
          tt-result.state-mass        = buf_rvs-line.state-measure-cli-qnty
          
          tt-result.level-total       = buf_rvs-line.level-total
          tt-result.density           = buf_rvs-line.density
          tt-result.asi-pomi-density  = ?
          tt-result.temperature       = buf_rvs-line.temperature
          tt-result.mass              = buf_rvs-line.measure-cli-qnty
          
          tt-result.diff-density-gram = ?
          tt-result.diff-density      = ?
          tt-result.diff-mass-kilo    = ABS(buf_rvs-line.state-measure-cli-qnty - buf_rvs-line.measure-cli-qnty)
          tt-result.diff-mass         = v-diff
                           
          tt-result.asi-type-name     = "Масса"
        .
      end .
    end case .
  end .
  
end procedure .

procedure print-report :
  run get-report-num (output p-report-id).
    
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
                        
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    { rep/htmlhead.i }
  .
                        
                        
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
  .

  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
    '<TR><TD colspan="23"></TD></TR>' skip
    '<TR>' skip
    '<TD colspan="23" style="font-weight: bold;">Отчет Результат проверки корректности работы АСИ в резервуаре</TD>' skip
    '</TR>'skip
                                
    '<TR>' skip
    '<TD colspan="23">' + v-period + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="23">Выбор объекта: ' + v-list-obj + '</TD>' skip
    '</TR>'skip


    '<TR>' skip
    '<TD colspan="23">' + v-print-date + '</TD>' skip
    '</TR>'skip

    '</thead>' skip
    
  .
  
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">№ п/п</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">АЗК/АЗС</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Дата смены</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Номер смены</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Номер документа проверки</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Дата документа проверки</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Марка НП</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Номер резервура</TH>' skip
    '<TH text_wrap="true" colspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Фактические замеры комиссии</TH>' skip
    '<TH text_wrap="true" colspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Данные замеров АСИ в резервуаре</TH>' skip
    '<TH text_wrap="true" colspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Результат расчета проверки</TH>' skip
    '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Тип проверки</TH>' skip
    '</TR>'skip 
    
    '<TR>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Уровень по метроштоку, см</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Плотность по замерам, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Плотность, приведенная к стандартной температуре, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Температура, С</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Масса, кг</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Уровень, см</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Плотность по уровнемеру, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Плотность с АСИ, приведенная к стандартной температуре, г/см3</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Температура, С</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Масса, кг</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Расхождение значения по плотности НП (г/см3)</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Расхождение значения по плотности НП (кг/м3)</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Расхождение по массе (кг)</TH>' skip
    '<TH text_wrap="true" rowspan="4" style="text-align: center; font-weight: bold; background-color: silver;">Расхождение в % по массе</TH>' skip
    '</TR>'skip  
    
    '<TR >'skip
    '</TR>'skip
    
    '<TR >'skip
    '</TR>'skip
    
    '<TR >'skip
    '</TR>'skip
    
    '<TR >'skip
    '<TH style="text-align: center; font-weight:bold; ">1</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">2</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">3</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">4</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">5</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">6</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">7</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">8</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">9</TH>'   skip
    '<TH style="text-align: center; font-weight:bold; ">10</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">11</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">12</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">13</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">14</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">15</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">16</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">17</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">18</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">19</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">20</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">21</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">22</TH>'  skip
    '<TH style="text-align: center; font-weight:bold; ">23</TH>'  skip
    '</TR>'skip    
  .
    
  for each tt-result by tt-result.num :
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TH style="text-align: center; font-weight: normal;">' + string(tt-result.num) + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + string(tt-result.obj-name) + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + string(tt-result.shift-date) + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + string(tt-result.shift-num) + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + tt-result.rvs-code + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + string(tt-result.doc-date) + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + tt-result.gds-name + '</TH>' skip
      '<TH style="text-align: center; font-weight: normal;">' + tt-result.loc1 + '</TH>' skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.state-level-total, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.state-level-total, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.izmer-density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.izmer-density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.pomi-density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.pomi-density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.state-temperature, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.state-temperature, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#,##0" val="'    + fDec2Str(tt-result.state-mass, "->>>>>>>>>>>9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.state-mass, "->>>>>>>>>>>9"  ) + '</TH>'  skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.level-total, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.level-total, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.asi-pomi-density, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.asi-pomi-density, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#,##0.0" val="'  + fDec2Str(tt-result.temperature, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.temperature, "->>>>>>>>>>>9.9"  ) + '</TH>'  skip
      '<TH num="#,##0" val="'    + fDec2Str(tt-result.mass, "->>>>>>>>>>>9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.mass, "->>>>>>>>>>>9"  ) + '</TH>'  skip
      '<TH num="#0.0000" val="'  + fDec2Str(tt-result.diff-density-gram, "-9.9999") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-density-gram, "-9.9999"  ) + '</TH>'  skip
      '<TH num="#,##0.00" val="' + fDec2Str(tt-result.diff-density, "->>>9.99") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-density, "->>>9.99"  ) + '</TH>'  skip
      '<TH num="#,##0" val="'    + fDec2Str(tt-result.diff-mass-kilo, "->>>>>>>>>>>9") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-mass-kilo, "->>>>>>>>>>>9"  ) + '</TH>'  skip
      '<TH num="#,##0.00" val="' + fDec2Str(tt-result.diff-mass, "->>>9.99") + '" style="text-align: center; font-weight: normal;">' + fDec2Str(tt-result.diff-mass, "->>>9.99"  ) + '</TH>'  skip
      '<TH text_wrap="true" style="text-align: center; font-weight: normal;">' + tt-result.asi-type-name + '</TH>' skip
      '</TR>'skip
    .
  end.


  put stream OutStr-html unformatted
    '</tbody>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
  .
                            
  output stream OutStr-html close.     
                                                                                                                
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).
    
end procedure .

PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

