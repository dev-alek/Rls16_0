block-level on error undo, throw.
/*
$Revision: 2d76561e6a10, 3381, rls $
$Author: EShklyar $
$Date: 2023/05/31 09:28:12 $
$Workfile: cash-param.p $
$Archive: rep/cash-param.p $
Отчет по анализу параметров АРМ Кассира
Автор: 
Дата 
Author: 
Creation date: 
*/

define variable vss-revision as character no-undo init "$Revision: 2d76561e6a10, 3381, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/31 09:28:12 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cash-param.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/cash-param.p $":U .
define variable vss-description as character no-undo init "Отчет по анализу параметров АРМ Кассира".
{cmp\vssrevis.i }
{cmp\trg-def.i}
/*{gbl\cd-attr.i}*/
{ cmp/r-page1.i  }
  { gbl/prn-lib.i }
  { gbl/tmprecid.i "shared"}
{ gbl/cash-list.i }
{ utl/cashparamHash.i }

FUNCTION getColor RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical  )  FORWARD.
   
FUNCTION getColorKey RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical  )  FORWARD.

FUNCTION getColorText RETURNS CHARACTER
  ( iscolor as char  )  FORWARD.
  
            define temp-table tt-param  
              field CashNum         as integer
              field ParamGroup      as character case-sensitive 
              field ParamName       as character case-sensitive
              field KeyboardNameDop as character
              field Device          as character
              field DeviceName      as character
              field DateTime        as decimal
              field ParamSection    as character
              field SectionName     as character
              field EtalonValue     as character
              field CurrentValue    as character
              field KeyboardName    as character
              field obj-code        as integer
              field obj-type        as character
              field obj-name        as character
              field flag            as character
              field diff            as logical
              field status_         as integer
              index pi is primary unique obj-code obj-type ParamGroup Device ParamSection CashNum ParamName KeyboardNameDop
              .
  
            define temp-table tt-choose-code
              field ParamName as character
              field section   as character
              field device    as character
              field group_    as character
              .
   
            define stream OutStr-html.
            define input  parameter parparentproc as handle no-undo.
            define input parameter parDesk as character no-undo .
            define input parameter parParam as character no-undo .
            define input parameter parSource as character no-undo .
            define input parameter table for tmprecid .
            define input parameter table for cash-list .

            define buffer buf_param for tt-param .
            define buffer buf_code  for ub.Code .

            define variable v-report-name-html-list as character no-undo .
            define variable v-sort                  as character no-undo .

            v-report-name-html-list = "CashPar_" + string(today,"99999999") + "_" + replace (string(time,"HH:MM"),":","") + ".html".
          
function fConvetDateTime returns character 
  (input iTStamp as dec):
   
  define variable vDateTime as datetime no-undo.
  define variable vDate     as date     no-undo.
  define variable vDays     as int64    no-undo.
  define variable vSec      as integer  no-undo.

  vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
  vDate = date("01/01/1970") + vDays.
  vSec = (int64(iTStamp) - vDays * 3600 * 24).
  return string(vDate,"99/99/9999") + " " + string(vSec, "HH:MM:SS").
   
end function.

            output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
            {rep/htmlhead.i}
              '<body>' skip
              '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
              '<thead>' skip
              ' <tr class="set_columns">' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:80px"></td>' skip
              ' <td style="width:150px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:100px"></td>' skip
              ' <td style="width:150px"></td>' skip
              '</tr>' skip .

  
            define buffer code-section        for ub.code. /*Параметры или клавиатура*/
            define buffer code-group          for ub.code. /*Группы*/
            define buffer code-device         for ub.code. /*Справочники*/
            define buffer code-param          for ub.code. /*Параметры*/
            define buffer buf_cash-param-hist for ub.cash-param-hist.   
            define buffer clients             for ub.clients.   
            define buffer buf_choose-code     for tt-choose-code .

            define variable v-attr-value   as character no-undo.
            define variable v-attr-type    as character no-undo.
            define variable vDeviceKind    as character no-undo.
            define variable cb-device-kind as integer   no-undo.
            define variable mdevice        as class     ibs.th.str.cash.CashDevice
              no-undo.
            define variable msection       as class     ibs.th.str.cash.CashSection
              no-undo.
            mdevice = new ibs.th.str.cash.CashDevice().
            msection = new ibs.th.str.cash.CashSection().

            if parParam = "choose" then 
            do:
              for each tmprecid no-lock where tmprecid.fTable = "code":
                for first ub.Code no-lock where recid(ub.Code) = tmprecid.Frecid:
                  create tt-choose-code.
                  tt-choose-code.device = entry(2,ub.Code.parent,{&delim-par}) .
                  tt-choose-code.section = entry(3,ub.Code.parent,{&delim-par}) .
                  tt-choose-code.group_ = entry(4,ub.Code.parent,{&delim-par}) no-error.
                  if tt-choose-code.group_ = "" then tt-choose-code.group_ = ub.Code.code .
                  else tt-choose-code.ParamName = ub.Code.code .
                end.
              end.
            end. 
            for each obj-list:
              for each cash-list no-lock where cash-list.obj-code = obj-list.obj-code:
                for each buf_cash-param-hist where buf_cash-param-hist.obj-code = obj-list.obj-code and
                  buf_cash-param-hist.obj-type = obj-list.obj-type and
                  buf_cash-param-hist.cash-num = cash-list.cash-num and
                  buf_cash-param-hist.device = integer(cash-list.deviceCode):
                  if parDesk <> "-1" then 
                    if lookup(string(buf_cash-param-hist.device), parDesk, ",") = 0 then next .
                  if parParam = "choose" then 
                  do:
                    find first tt-choose-code where tt-choose-code.section = buf_cash-param-hist.param_section and 
                      tt-choose-code.device = string(buf_cash-param-hist.device) and 
                      tt-choose-code.group_ = string(buf_cash-param-hist.param_group) no-error .
                    if available tt-choose-code then 
                    do:
                      if tt-choose-code.ParamName <> "" then 
                      do:
                        find first buf_choose-code where buf_choose-code.section = buf_cash-param-hist.param_section and 
                          buf_choose-code.device = string(buf_cash-param-hist.device) and 
                          buf_choose-code.group_ = string(buf_cash-param-hist.param_group) and
                          buf_choose-code.ParamName = string(buf_cash-param-hist.param_name) no-error .
                        if not available (buf_choose-code) then next .
                      end.  
                    end.
                    else next .
                  end.  
                  create tt-param .
                  assign
                    tt-param.obj-code        = buf_cash-param-hist.obj-code
                    tt-param.obj-type        = buf_cash-param-hist.obj-type
                    tt-param.CashNum         = buf_cash-param-hist.cash-num
                    tt-param.ParamGroup      = buf_cash-param-hist.param_group
                    tt-param.ParamName       = buf_cash-param-hist.param_name
                    tt-param.CurrentValue    = buf_cash-param-hist.param_value
                    tt-param.Device          = string(buf_cash-param-hist.device)
                    tt-param.ParamSection    = buf_cash-param-hist.param_section
                    tt-param.KeyboardName    = buf_cash-param-hist.param_value_dop
                    tt-param.flag            = "current"
                    tt-param.DateTime        = buf_cash-param-hist.tstamp
                    tt-param.KeyBoardNameDop = buf_cash-param-hist.param_name
                    .
                  tt-param.DeviceName   = mdevice:GetLabel(buf_cash-param-hist.device).
                  tt-param.SectionName   = msection:GetLabel(int(buf_cash-param-hist.param_section)).
      
                  find first clients no-lock where clients.obj-code = tt-param.obj-code and
                    clients.obj-type = tt-param.obj-type no-error .
                  if available (clients) then tt-param.obj-name = clients.obj-name .
                end.
              end.
            end.

            /* Признаки исполнения кассы */
            for each code-device where code-device.parent = "cash-param" no-lock:
              if parDesk <> "-1" then 
                if lookup(string(code-device.code), parDesk, ",") = 0 then next .
              /* Параметры или клавиатура */
              for each code-section where code-section.parent = code-device.parent + {&delim-par} + code-device.code no-lock:
                /*Группы*/
                for each code-group where code-group.parent = code-section.parent + {&delim-par} + code-section.code no-lock:
                  /* Параметры детально */
                  for each code-param where code-param.parent = code-group.parent + {&delim-par} + code-group.code no-lock:
                    if parParam = "choose" then 
                    do:
                      find first tt-choose-code where tt-choose-code.section = code-section.code and 
                        tt-choose-code.device = code-device.code and 
                        tt-choose-code.group_ = code-group.code no-error .
                      if available tt-choose-code then 
                      do:
                        if tt-choose-code.ParamName <> "" then 
                        do:
                          find first buf_choose-code where buf_choose-code.section = code-section.code and 
                            buf_choose-code.device = code-device.code and 
                            buf_choose-code.group_ = code-group.code and
                            buf_choose-code.ParamName = code-param.code no-error .
                          if not available (buf_choose-code) then next .
                        end.  
                      end.
                      else next .
                    end. 
                    for each obj-list:
                      for each cash-list where cash-list.obj-code = obj-list.obj-code and cash-list.deviceCode = code-device.code:
                        if code-section.code = "1" then 
                        do:
                          find first tt-param exclusive-lock where tt-param.ParamGroup = code-group.code and 
                            tt-param.obj-code = obj-list.obj-code and
                            tt-param.obj-type = obj-list.obj-type and
                            tt-param.ParamName = code-param.code and
                            tt-param.ParamSection = code-section.code and
                            tt-param.CashNum = cash-list.cash-num and
                            tt-param.Device = cash-list.deviceCode no-error .
                          if not available (tt-param) then 
                          do:
                            create tt-param .
                            assign
                              tt-param.obj-code     = obj-list.obj-code
                              tt-param.obj-type     = obj-list.obj-type
                              tt-param.ParamGroup   = code-group.code
                              tt-param.Device       = code-device.code
                              tt-param.ParamSection = code-section.code
                              tt-param.ParamName    = code-param.code
                              tt-param.flag         = "etalon"
                              tt-param.diff         = true
                              tt-param.CashNum      = cash-list.cash-num
                              .
                            tt-param.DeviceName   = mdevice:GetLabel(int(code-device.code)) .      
                            tt-param.SectionName  =  msection:GetLabel(int(code-section.code)).   
                      
                          end.
                          else tt-param.flag = "" .
                          assign
                            tt-param.EtalonValue = code-param.CodeValue
                            tt-param.status_     = code-param.status_
                            .
                        end.
                        else 
                        do:
                          find first tt-param exclusive-lock where tt-param.ParamGroup = code-group.code and 
                            tt-param.obj-code = obj-list.obj-code and
                            tt-param.obj-type = obj-list.obj-type and
                            tt-param.ParamSection = code-section.code and
                            tt-param.KeyBoardNameDop = code-param.code and
                            tt-param.CashNum = cash-list.cash-num and
                            tt-param.Device = cash-list.deviceCode no-error .              
                          if not available (tt-param) then 
                          do:
                            create tt-param .
                            assign
                              tt-param.obj-code        = obj-list.obj-code
                              tt-param.obj-type        = obj-list.obj-type
                              tt-param.ParamGroup      = code-group.code
                              tt-param.Device          = code-device.code
                              tt-param.ParamSection    = code-section.code
                              tt-param.KeyBoardNameDop = code-param.code
                              tt-param.flag            = "etalon"
                              tt-param.diff            = true
                              tt-param.CashNum         = cash-list.cash-num
                              .
                            tt-param.DeviceName   = mdevice:GetLabel(int(code-device.code)) .      
                            tt-param.SectionName  =  msection:GetLabel(int(code-section.code)).                         
                          end.
                          else tt-param.flag = "" .
                          assign
                            tt-param.EtalonValue = code-param.CodeValue
                            tt-param.status_     = code-param.status_
                            .
                        end.
                        if tt-param.CurrentValue <> tt-param.EtalonValue and tt-param.flag = "" then tt-param.diff = true .

                        find first clients no-lock where clients.obj-code = tt-param.obj-code and
                          clients.obj-type = tt-param.obj-type no-error .
                        if available (clients) then tt-param.obj-name = clients.obj-name .
                      end.
                    end.  
                  end.
                end.   
              end.
            end.

            case parParam:
              when "mandatory" then 
                do:
                  for each tt-param exclusive-lock where tt-param.flag = "current" or (tt-param.status_ = {&bef-deleted-status-int} and tt-param.flag <> "current"):
                    delete tt-param .
                  end. 
                end.
              when "optional" then 
                do:
                  for each tt-param exclusive-lock where tt-param.flag = "current" or (tt-param.status_ = {&bef-current-status-int} and tt-param.flag <> "current"):
                    delete tt-param .
                  end.     
                end.
              when "diff" then 
                do:
                  for each tt-param exclusive-lock where not tt-param.diff and tt-param.flag = "":
                    delete tt-param .
                  end.      
                end.
            end.

            define variable cashQntyCheck       as integer no-undo .
            define variable diffCashParam       as integer no-undo .
            define variable diffCashKeyBoard    as integer no-undo .
            define variable withoutCashParam    as integer no-undo .
            define variable withoutCashKeyBoard as integer no-undo .
      
            for each obj-list no-lock where obj-list.obj-type = {&shop}:          
              for each cash-list no-lock where cash-list.obj-code = obj-list.obj-code:
                cashQntyCheck = cashQntyCheck + 1 .
                if can-find (first buf_param no-lock where buf_param.CashNum = cash-list.cash-num and 
                  buf_param.obj-code = cash-list.obj-code and 
                  buf_param.SectionName = "Параметры" and
                  (buf_param.diff or buf_param.flag <> "")) then diffCashParam = diffCashParam + 1 .
                else withoutCashParam = withoutCashParam + 1 . 
                if can-find (first buf_param no-lock where buf_param.CashNum = cash-list.cash-num and 
                  buf_param.obj-code = cash-list.obj-code and 
                  buf_param.SectionName <> "Параметры" and
                  (buf_param.diff or buf_param.flag <> "")) then
                  diffCashKeyBoard = diffCashKeyBoard + 1 .
                else withoutCashKeyBoard = withoutCashKeyBoard + 1 . 
              end.
            end.

            put stream OutStr-html unformatted
              '<tr><!-- шапка таблицы -->' skip
              '<td colspan="11" style="text-align: right;"></td>' skip
              '</tr>' skip
              '<tr>' skip
              '<td colspan="11" style="text-align: right;">Дата формирования ' + string(today,"99.99.9999") + " " + string(time,"HH:MM:SS") + '</td>'
              '</tr>' skip
              '<tr>' skip
              '<td colspan="11" style="font-weight: bold; text-align: center;">Отчет по анализу параметров АРМ Кассира</td>' skip
              '</tr>' skip
              '<tr>' skip
              '<td colspan="11" style="text-align: left;">Кол-во проверенных касс: ' + string(cashQntyCheck) + '</td>'
              '</tr>' skip
              .
            if parSource <> "keyboard" then 
            do:
              put stream OutStr-html unformatted  
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     с замечаниями по параметрам: ' + string(diffCashParam) + '</td>'
                '</tr>' skip .
            end.
            if parSource <> "param" then 
            do:  
              put stream OutStr-html unformatted  
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     с замечаниями по клавиатуре: ' + string(diffCashKeyBoard) + '</td>'
                '</tr>' skip
                .
            end.
            if parSource <> "keyboard" then 
            do:  
              put stream OutStr-html unformatted  
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     без замечаний по параметрам: ' + string(withoutCashParam) + '</td>'
                '</tr>' skip
                .
            end.  
            if parSource <> "param" then 
            do:  
              put stream OutStr-html unformatted  
                '<tr>' skip
                '<td colspan="11" style="text-align: left;">     без замечаний по клавиатуре: ' + string(withoutCashKeyBoard) + '</td>'
                '</tr>' skip
                .
            end. 
            put stream OutStr-html unformatted  
              '</thead>' skip
              '<tr>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Название АЗК/АЗС</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Признак исполнения кассы</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Номер кассы</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Дата и время актуальной сверки</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Наименование источника</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Раздел/Наименование функции клавиши</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Наименование параметра/Дополнительное значение</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Тип клавиатуры</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Значение параметра/Степень защиты эталон</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Значение параметра/Степень защиты текущее</td>' skip
              '<td text_wrap="true" style="text-align: center; border: 1px solid black;">Результат сравнения</td>' skip
              '</tr>' skip
              '<tbody>' 
              .

            define variable v-first as logical   no-undo .
            define variable v-color as character no-undo .

            if parSource <> "keyboard" then 
            do:
              for each tt-param no-lock where tt-param.SectionName = "Параметры" by tt-param.obj-code by tt-param.obj-type by tt-param.CashNum by tt-param.ParamGroup by tt-param.KeyBoardName:
                if not v-first then 
                do:
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td colspan="11" text_wrap="true" style="">' tt-param.SectionName '</td>' skip 
                    '</tr>' skip
                    .    
                end.
                v-first = true .
                v-color = getColor(tt-param.flag, tt-param.status_, tt-param.diff) .
 
                put stream OutStr-html unformatted
                  '<tr>' skip
                  '<td text_wrap="true">' tt-param.obj-name  '</td>' skip
                  '<td text_wrap="true">' tt-param.DeviceName '</td>' skip
                  '<td text_wrap="true">' tt-param.CashNum '</td>' skip
                  '<td text_wrap="true">' if tt-param.DateTime = 0 then "" else fConvetDateTime(tt-param.DateTime) '</td>' skip
                  '<td text_wrap="true">' tt-param.SectionName '</td>' skip
                  '<td text_wrap="true">' tt-param.ParamGroup '</td>' skip
                  '<td text_wrap="true">' tt-param.ParamName '</td>' skip
                  '<td text_wrap="true">' tt-param.KeyBoardName '</td>' skip   
                  '<td text_wrap="true">' tt-param.EtalonValue '</td>' skip
                  '<td text_wrap="true">' tt-param.CurrentValue '</td>' skip
                  '<td text_wrap="true" style="background-color: ' + v-color + ';">' getColorText(v-color) '</td>' skip   
                  /*                                      '<td text_wrap="true" style="">' tt-param.flag '</td>' skip   */
                  /*                                      '<td text_wrap="true" style="">' tt-param.diff '</td>' skip   */
                  /*                                      '<td text_wrap="true" style="">' tt-param.status_ '</td>' skip*/
                  '</tr>' skip
                  .
              end.
            end.
            v-first = false .
            if parSource <> "param" then 
            do:
              for each tt-param no-lock where tt-param.SectionName <> "Параметры" by tt-param.obj-code by tt-param.obj-type by tt-param.CashNum by tt-param.ParamGroup by tt-param.KeyBoardName by tt-param.KeyBoardNameDop:
                for first buf_code exclusive-lock where buf_code.code = tt-param.ParamGroup and buf_code.parent = "cashFunKey":
                  tt-param.ParamGroup = buf_code.code + " " + buf_code.misc1 + " " + buf_code.CodeName .
                end.
                if not v-first then 
                do:
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td colspan="11" text_wrap="true" style="">' tt-param.SectionName '</td>' skip 
                    '</tr>' skip
                    .    
                end.  
                v-first = true .
                v-color = getColorKey(tt-param.flag, tt-param.status_, tt-param.diff) .
                put stream OutStr-html unformatted
                  '<tr>' skip
                  '<td text_wrap="true">' tt-param.obj-name  '</td>' skip
                  '<td text_wrap="true">' tt-param.DeviceName '</td>' skip
                  '<td text_wrap="true">' tt-param.CashNum '</td>' skip
                  '<td text_wrap="true">' if tt-param.DateTime = 0 then "" else fConvetDateTime(tt-param.DateTime) '</td>' skip
                  '<td text_wrap="true">' tt-param.SectionName '</td>' skip
                  '<td text_wrap="true">' tt-param.ParamGroup '</td>' skip
                  '<td text_wrap="true">' tt-param.KeyBoardNameDop '</td>' skip
                  '<td text_wrap="true">' tt-param.KeyBoardName '</td>' skip   
                  '<td text_wrap="true">' tt-param.EtalonValue '</td>' skip
                  '<td text_wrap="true">' tt-param.CurrentValue '</td>' skip   
                  '<td text_wrap="true" style="background-color: ' + v-color + ';">' getColorText(v-color) '</td>' skip
                  /*                                      '<td text_wrap="true" style="">' tt-param.flag '</td>' skip   */
                  /*                                      '<td text_wrap="true" style="">' tt-param.diff '</td>' skip   */
                  /*                                      '<td text_wrap="true" style="">' tt-param.status_ '</td>' skip*/
                  '</tr>' skip
                  .
              end.    
            end.
            if g#db-num = 0 then 
            do:
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td text_wrap="true" colspan = "11" style="background-color:#D8EEC0; text-align: center;">Контрольные суммы справочника ЭЗ</td>' skip
                '</tr>' skip
                '<tr>' skip
                '<td colspan = "3" text_wrap="true" style="background-color:#D8EEC0; text-align: center;">Название АЗК/АЗС</td>' skip
                '<td colspan = "4" text_wrap="true" style="background-color:#D8EEC0; text-align: center;">Контрольная сумма совпадает</td>' skip
                '<td colspan = "4" text_wrap="true" style="background-color:#D8EEC0; text-align: center;">Контрольная сумма не совпадает</td>' skip
                '</tr>' skip
                .
              define variable trueControlSum  as character no-undo .
              define variable falseControlSum as character no-undo .
              define variable vhashcode       as character no-undo.
              vhashcode = getCashparamHash().
              for each obj-list where obj-list.obj-type = {&shop}:
                trueControlSum = "" .
                falseControlSum = "" .
                if vhashcode <> getCashParamHashDb(obj-list.db) then 
                do:
                  falseControlSum = "Да" .
                  v-color = "#FFB3B3" .
                end.
                else 
                do:
                  trueControlSum = "Да" .
                  v-color = "white" .
                end.        
        
                put stream OutStr-html unformatted
                  '<tr>' skip
                  '<td colspan = "3" text_wrap="true" style="background-color:' + v-color + '; text-align: left;">' + obj-list.obj-name + '</td>' skip
                  '<td colspan = "4" text_wrap="true" style="background-color:' + v-color + '; text-align: right;">' + trueControlSum + '</td>' skip
                  '<td colspan = "4" text_wrap="true" style="background-color:' + v-color + '; text-align: right;">' + falseControlSum + '</td>' skip
                  '</tr>' skip
                  .        
              end.

            end.      
            put stream OutStr-html unformatted
              '<tbody>' skip
              '</table>'
              .

            output stream OutStr-html close.   
            run prn-lib-reportviewer in this-procedure (
              input parparentproc
              ,input v-report-name-html-list
              ,input "" 
              ) no-error.
            if error-status:error then
            do:
              message return-value view-as alert-box.
              return .
            end.


FUNCTION getColor RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical ):
  case istatus:
    when {&bef-current-status-int} or 
    when 2 then /*обязательный*/ 
      do:
        if isflag = "etalon" then return "#FFDD71" /*"orange" */.
        else if isflag = "current" then return "#ffffe0" /*"yellow"*/ .
          else if isdiff then return "#FFB3B3" /*"red"*/ .
            else return "#D8EEC0" /*"green"*/ .
      end.
    when {&bef-deleted-status-int} or 
    when 1 then 
      do:
        return "#D5EAFF" /*" "blue" */.
      end.
    otherwise 
    do:
      if isflag = "current" then return "#ffffe0" /*"yellow"*/ .
    end.
  end case.
end.

FUNCTION getColorKey RETURNS CHARACTER
  ( isflag as char, istatus as int, isdiff as logical ):
  case istatus:
    when {&bef-current-status-int} or 
    when 2 then /*обязательный*/ 
      do:
        if isflag = "etalon" then return "#FFDD71" /*"orange" */.
        else if isflag = "current" then return "#ffffe0" /*"yellow"*/ .
          else if isdiff then return "#FFB3B3" /*"red"*/ .
            else return "#D8EEC0" /*"green"*/ .
      end.
    when {&bef-deleted-status-int} or 
    when 1 then 
      do:
        if isflag = "current" then return "#ffffe0" /*"yellow"*/ .
        else return "#D5EAFF" /*" "blue" */.
      end.
    otherwise 
    do:
      if isflag = "current" then return "#ffffe0" /*"yellow"*/ .
    end.
  end case.
end.

FUNCTION getColorText RETURNS CHARACTER
  ( iscolor as char ):
  case iscolor:
    when "#FFDD71" then /*"orange" */ 
      do:
        return "Не настроен на кассе" .
      end.    
    when "#FFB3B3" then /*"red" */ 
      do:
        return "Не соответствует эталону (РПД/ИА)" .
      end.    
    when "#D8EEC0" then /*"green" */ 
      do:
        return "Соответствует эталону (РПД/ИА)" .
      end.    
    when "#D5EAFF" then /*"blue" */ 
      do:
        return "Необязательный параметр (SiteSpecific)" .
      end.    
    when "#ffffe0" then /*"yellow" */ 
      do:
        return "Отсутствует в эталоне, но есть на кассе" .
      end.                
    otherwise 
    do:
      return "" .
    end.
  end case.
end.
/*          output to tt-param.txt .*/
/*          for each tt-param:      */
/*            export tt-param .     */
/*          end.                    */
/*          output close .          */