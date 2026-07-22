/*

$Revision: 62b337b2b107, 1578, rls $
$Author: EShklyar $
$Date: Tue Nov 06 04:41:35 2018 +0300 $
$Workfile: print_NormLoss.p $
$Archive: rep/print_NormLoss.p $

Нормы технологических потерь

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.str.*.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: 62b337b2b107, 1578, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:35 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: print_NormLoss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/print_NormLoss.p $":U .
define variable vss-description as character no-undo init "Нормы технологических потерь".
{ cmp/vssrevis.i }

define input parameter parParentProc as widget-handle     no-undo .
define input parameter p-type        as integer           no-undo .

{ gbl/std-func.i {&f-l} }
define stream out-stream.

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/w-rep.i    }
{ rep/fmtcli.i   }
{ rep/torgconf.i }
{ str/getctxtp.i def }
{ gbl/paramls.i  }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }

    
define stream Out-Stream.
define stream OutStr-html.

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .

define buffer buf_norm-loss for ub.norm-loss.

define temp-table tt-norm-loss no-undo
  field clim-grp   as character
  field position   as character
  field oil-grp    as character
  field season     as character
  field value-loss as decimal
  field type-id    as integer
  field sec-vol1   as decimal
  field sec-vol2   as decimal
  field id         as integer
  index pi id
  asc sec-vol1
  . 

define temp-table tt-norm-1 no-undo
  field sec-vol  as character
  field sec-vol1 as decimal
  field sec-vol2 as decimal
  field season   as character
  field type-id  as integer
  field pol3     as decimal
  field pol4     as decimal
  field pol5     as decimal
  field pol6     as decimal
  field pol7     as decimal
  field pol8     as decimal
  field pol9     as decimal
  field pol10    as decimal
  field pol11    as decimal
  field pol12    as decimal
  field pol13    as decimal
  field pol14    as decimal
  field pol15    as decimal
  field pol16    as decimal
  field pol17    as decimal
  field pol18    as decimal
  field pol19    as decimal
  field pol20    as decimal
  field pol21    as decimal
  field pol22    as decimal
  field pol23    as decimal
  index pi season sec-vol
  . 
    
define temp-table tt-norm-2 no-undo
  field clim-grp  as character
  field position1 as character
  field position2 as character
  field pol3      as decimal
  field pol4      as decimal
  field pol5      as decimal
  field pol6      as decimal
  field pol7      as decimal
  field pol8      as decimal
  field pol9      as decimal
  field pol10     as decimal
  field pol31     as decimal
  field pol41     as decimal
  field pol51     as decimal
  field pol61     as decimal
  field pol71     as decimal
  field pol81     as decimal
  field pol91     as decimal
  field pol01     as decimal
  field type-id   as integer
  index pi clim-grp 
  . 

define buffer buf_ttNL      for tt-norm-loss .  
define buffer buf_tt-norm-1 for tt-norm-1 .
define buffer buf_tt-norm-2 for tt-norm-2 .

do
  on error undo, return error return-value
  :
  /*Сбор данных*/
  
  for each buf_norm-loss no-lock :
      
    create tt-norm-loss .
    buffer-copy buf_norm-loss except buf_norm-loss.type buf_norm-loss.season buf_norm-loss.position to tt-norm-loss no-error .
    tt-norm-loss.type-id = buf_norm-loss.type .
    if buf_norm-loss.season = 0 then tt-norm-loss.season = "Весенне-Летний" .
    else tt-norm-loss.season = "Осенне-Зимний" .
    if buf_norm-loss.position = "0" then tt-norm-loss.position = "наземный" .
    else tt-norm-loss.position = "подземный" .
  end.

  if p-type = 1 then 
  do:
    for each buf_ttNL where buf_ttNL.type-id = p-type break by buf_ttNL.sec-vol1:
      find first buf_tt-norm-1 where buf_tt-norm-1.sec-vol1 = buf_ttNL.sec-vol1 and buf_tt-norm-1.sec-vol2 = buf_ttNL.sec-vol2 and buf_tt-norm-1.season = buf_ttNL.season no-error .
      if not available (buf_tt-norm-1) then 
      do:
        create buf_tt-norm-1 .
        assign
          buf_tt-norm-1.season   = buf_ttNL.season
          buf_tt-norm-1.sec-vol1 = buf_ttNL.sec-vol1
          buf_tt-norm-1.sec-vol2 = buf_ttNL.sec-vol2
          .
        if buf_ttNL.sec-vol2 <> 0 and buf_ttNL.sec-vol1 <> 0 then 
        do:
          buf_tt-norm-1.sec-vol = "Более " + string(buf_ttNL.sec-vol1) +
            " до " + string(buf_ttNL.sec-vol2) + " вкл".
        end.
        else 
        do:
          if buf_ttNL.sec-vol1 = 0 then 
          do: 
            buf_tt-norm-1.sec-vol = "До " + string (buf_ttNL.sec-vol2) + " вкл" . 
          end. 
          if buf_ttNL.sec-vol2 = 0 then 
          do: 
            buf_tt-norm-1.sec-vol = "Более " + string (buf_ttNL.sec-vol1) . 
          end.
        end.
      end.  
      case buf_ttNL.clim-grp:
        when "1 (1)" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" or 
              when "II" then 
                do:
                  buf_tt-norm-1.pol3 = buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  buf_tt-norm-1.pol4 = buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  buf_tt-norm-1.pol5 = buf_ttNL.value-loss .
                end.      
            end.  
          end.
        when "1 (2)" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" or 
              when "II" then 
                do:
                  buf_tt-norm-1.pol6 = buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  buf_tt-norm-1.pol7 = buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  buf_tt-norm-1.pol8 = buf_ttNL.value-loss .
                end.
            end.
          end.
        when "2 (1)" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" or 
              when "II" then 
                do:
                  buf_tt-norm-1.pol9 = buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  buf_tt-norm-1.pol10 = buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  buf_tt-norm-1.pol11 = buf_ttNL.value-loss .
                end.
            end.
          end.
        when "2 (2)" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" or 
              when "II" then 
                do:
                  buf_tt-norm-1.pol12 = buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  buf_tt-norm-1.pol13 = buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  buf_tt-norm-1.pol14 = buf_ttNL.value-loss .
                end.
            end.
          end.
        when "2 (3)" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" or 
              when "II" then 
                do:
                  buf_tt-norm-1.pol15 = buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  buf_tt-norm-1.pol16 = buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  buf_tt-norm-1.pol17 = buf_ttNL.value-loss .
                end.
            end.
          end.
        when "3 (1)" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" or 
              when "II" then 
                do:
                  buf_tt-norm-1.pol18 = buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  buf_tt-norm-1.pol19 = buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  buf_tt-norm-1.pol20 = buf_ttNL.value-loss .
                end.
            end.
          end.
        when "3 (2)" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" or 
              when "II" then 
                do:
                  buf_tt-norm-1.pol21 = buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  buf_tt-norm-1.pol22 = buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  buf_tt-norm-1.pol23 = buf_ttNL.value-loss .
                end.
            end.  
          end.  
      end.
    end.  
  end.  
  else 
  do:
    for each buf_ttNL where buf_ttNL.type-id = p-type:
      find first buf_tt-norm-2 where buf_tt-norm-2.clim-grp = buf_ttNL.clim-grp no-error .
      if not available (buf_tt-norm-2) then 
      do:
        create buf_tt-norm-2 .
        assign
          buf_tt-norm-2.clim-grp = buf_ttNL.clim-grp
          .
      end.  
        if buf_ttNL.position = "наземный" then buf_tt-norm-2.position1 = buf_ttNL.position .
        else buf_tt-norm-2.position2 = buf_ttNL.position .
      case buf_ttNL.season:
        when "Осенне-Зимний" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol9 = buf_tt-norm-2.pol9 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol91 = buf_tt-norm-2.pol91 + buf_ttNL.value-loss .
                end.   
              when "II" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol3 = buf_tt-norm-2.pol3 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol31 = buf_tt-norm-2.pol31 + buf_ttNL.value-loss .
                end.   
              when "III" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol5 = buf_tt-norm-2.pol5 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol51 = buf_tt-norm-2.pol51 + buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol7 = buf_tt-norm-2.pol7 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol71 = buf_tt-norm-2.pol71 + buf_ttNL.value-loss .
                end.      
            end.  
          end.
        when "Весенне-Летний" then 
          do:
            case buf_ttNL.oil-grp:
              when "I" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol10 = buf_tt-norm-2.pol10 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol01 = buf_tt-norm-2.pol01 + buf_ttNL.value-loss .
                end.
              when "II" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol4 = buf_tt-norm-2.pol4 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol41 = buf_tt-norm-2.pol41 + buf_ttNL.value-loss .
                end.
              when "III" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol6 = buf_tt-norm-2.pol6 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol61 = buf_tt-norm-2.pol61 + buf_ttNL.value-loss .
                end.
              when "IV" then 
                do:
                  if buf_tt-norm-2.position1 = buf_ttNL.position then buf_tt-norm-2.pol8 = buf_tt-norm-2.pol8 + buf_ttNL.value-loss .
                  else buf_tt-norm-2.pol81 = buf_tt-norm-2.pol81 + buf_ttNL.value-loss .
                end.
            end.
          end.
      end.
    end.  
  end.  

  /*печать*/
  run get-report-num (output p-report-id).

  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".

  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
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
    /*Первая таблица*/
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
    
  if p-type = 1 then do:  
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '</tr>' skip
    '<TR><td colspan="23" style="text-align: center; font-weight: bold;">Нормы технологических потерь нефтепродуктов от неполного слива и налипания на внутренние поверхности автомобильных цистерн
(в килограммах на одну АЦ, секцию многосекционной АЦ)
    </td></TR>' skip
    '</thead>' skip
    '<tbody>' skip
    .

  run print-table1 no-error .

  put stream OutStr-html unformatted
    '</tbody>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
end.
else do:
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '</tr>' skip
    '<TR><td colspan="10" style="text-align: center; font-weight: bold;">Нормы технологических потерь нефтепродуктов при приеме в резервуары горизонтальные стальные
(в килограммах на 1 тонну принятого нефтепродукта)
    </td></TR>' skip
    '</thead>' skip
    '<tbody>' skip
    .

  run print-table2 no-error .

  put stream OutStr-html unformatted
    '</tbody>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
end.
  output stream OutStr-html close.

  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).
end.

/* **********************  Internal Procedures  *********************** */
PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

procedure print-table1:

  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" rowspan="4" style="text-align: center;">Вместимость цистерны (секции цистерны), м3</TD>' skip
    '<TD text_wrap="true" rowspan="4" style="text-align: center;">Период года</TD>' skip
    '<TD text_wrap="true" colspan="21" style="text-align: center;">Климатическая группа (подгруппа)</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">1(1)</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">1(2)</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">2(1)</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">2(2)</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">2(3)</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">3(1)</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">3(2)</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="21" style="text-align: center;">Группа нефтепродуктов</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD style="text-align: center;">I, II</TD>' skip
    '<TD style="text-align: center;">III</TD>' skip
    '<TD style="text-align: center;">IV</TD>' skip
    '<TD style="text-align: center;">I, II</TD>' skip
    '<TD style="text-align: center;">III</TD>' skip
    '<TD style="text-align: center;">IV</TD>' skip
    '<TD style="text-align: center;">I, II</TD>' skip
    '<TD style="text-align: center;">III</TD>' skip
    '<TD style="text-align: center;">IV</TD>' skip
    '<TD style="text-align: center;">I, II</TD>' skip
    '<TD style="text-align: center;">III</TD>' skip
    '<TD style="text-align: center;">IV</TD>' skip
    '<TD style="text-align: center;">I, II</TD>' skip
    '<TD style="text-align: center;">III</TD>' skip
    '<TD style="text-align: center;">IV</TD>' skip
    '<TD style="text-align: center;">I, II</TD>' skip
    '<TD style="text-align: center;">III</TD>' skip
    '<TD style="text-align: center;">IV</TD>' skip
    '<TD style="text-align: center;">I, II</TD>' skip
    '<TD style="text-align: center;">III</TD>' skip
    '<TD style="text-align: center;">IV</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD style="text-align: center;">1</TD>' skip
    '<TD style="text-align: center;">2</TD>' skip
    '<TD style="text-align: center;">3</TD>' skip
    '<TD style="text-align: center;">4</TD>' skip
    '<TD style="text-align: center;">5</TD>' skip
    '<TD style="text-align: center;">6</TD>' skip
    '<TD style="text-align: center;">7</TD>' skip
    '<TD style="text-align: center;">8</TD>' skip
    '<TD style="text-align: center;">9</TD>' skip
    '<TD style="text-align: center;">10</TD>' skip
    '<TD style="text-align: center;">11</TD>' skip
    '<TD style="text-align: center;">12</TD>' skip
    '<TD style="text-align: center;">13</TD>' skip
    '<TD style="text-align: center;">14</TD>' skip
    '<TD style="text-align: center;">15</TD>' skip
    '<TD style="text-align: center;">16</TD>' skip
    '<TD style="text-align: center;">17</TD>' skip
    '<TD style="text-align: center;">18</TD>' skip
    '<TD style="text-align: center;">19</TD>' skip
    '<TD style="text-align: center;">20</TD>' skip
    '<TD style="text-align: center;">21</TD>' skip
    '<TD style="text-align: center;">22</TD>' skip
    '<TD style="text-align: center;">23</TD>' skip
    '</TR>'skip

    .
  for each tt-norm-1 break by tt-norm-1.sec-vol1:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.sec-vol) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.season) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol3) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol4) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol5) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol6) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol7) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol8) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol9) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol10) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol11) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol12) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol13) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol14) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol15) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol16) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol17) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol18) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol19) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol20) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol21) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol22) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-1.pol23) + '</TD>' skip
      '</TR>'skip
      .
  end.
end procedure .


procedure print-table2:

  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" rowspan="3" style="text-align: center;">Климатическа группа (подгруппа)</TD>' skip
    '<TD text_wrap="true" rowspan="3" style="text-align: center;">Тип резервуара</TD>' skip
    '<TD text_wrap="true" colspan="8" style="text-align: center;">Группа Нефтепродуктов</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">I</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">II</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">III</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">IV</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">Осенне-зимний период</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Весенне-летний период</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Осенне-зимний период</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Весенне-летний период</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Осенне-зимний период</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Весенне-летний период</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Осенне-зимний период</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Весенне-летний период</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD style="text-align: center;">1</TD>' skip
    '<TD style="text-align: center;">2</TD>' skip
    '<TD style="text-align: center;">3</TD>' skip
    '<TD style="text-align: center;">4</TD>' skip
    '<TD style="text-align: center;">5</TD>' skip
    '<TD style="text-align: center;">6</TD>' skip
    '<TD style="text-align: center;">7</TD>' skip
    '<TD style="text-align: center;">8</TD>' skip
    '<TD style="text-align: center;">9</TD>' skip
    '<TD style="text-align: center;">10</TD>' skip
    '</TR>'skip
    .

  for each tt-norm-2 by tt-norm-2.clim-grp:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" rowspan="2" style="text-align: left;">' + string(tt-norm-2.clim-grp) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-2.position1) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol9,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol9,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol10,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol10,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol3,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol3,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol4,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol4,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol5,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol5,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol6,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol6,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol7,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol7,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol8,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol8,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-norm-2.position2) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol91,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol91,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol01,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol01,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol31,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol31,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol41,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol41,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol51,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol51,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol61,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol61,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol71,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol71,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD val="' + fnc-convert-dot-to-colon(tt-norm-2.pol81,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-norm-2.pol81,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '</TR>'skip
      .
  end.
end procedure .
