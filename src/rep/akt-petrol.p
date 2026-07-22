/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акт приема нефтепродуктов

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.str.*.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Акт приема нефтепродуктов".
{ cmp/vssrevis.i }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U
/* Для вызова функции конвертации даты к виду: "01 Января 2014г" */
&scop f-l MonthNameRusCase

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
{ str/placelib.i }

    
define variable is-petrolium         as logical   no-undo.
define variable is-pieces            as logical   no-undo.
define variable v-doc-code           like ub.trn-doc.doc-code no-undo .
define variable v-gds-code           like ub.goods.gds-code no-undo .
define variable v-fio                as character no-undo .
define variable v-InfoSectionsTotal  as class     InfoSectionsTotal no-undo .
define variable v-InfoSection        as class     InfoSection       no-undo .
define variable iNum                 as integer   no-undo .
define variable jj                   as integer   no-undo .
define variable v-producer           as character no-undo .
define variable v-obj-name           as character no-undo .
define variable v-driver             as character no-undo .       
define variable v-car-num            as character no-undo . 
define variable v-car-type           as character no-undo .          
define VARIABLE v-gds-name           as character no-undo .        
define VARIABLE v-num-prob           as character no-undo .
DEFINE VARIABLE v-norm-doc           as character no-undo .
define VARIABLE v-kol-prob           as decimal   no-undo .
define VARIABLE v-tank-vol           as decimal   no-undo .
DEFINE VARIABLE v-tank-density       as DECIMAL   no-undo .
define VARIABLE v-tank-weight        as decimal   no-undo .
define variable v-tank-temp          as decimal   no-undo .
define variable v-date-prob          as date      no-undo .
define variable v-ship-date          as date      no-undo .
define variable v-hour-prob          as integer   no-undo .
define variable v-min-prob           as integer   no-undo .
define VARIABLE v-obj-adress         as character no-undo .
define VARIABLE v-carrier            as character no-undo .
define variable v-date-prob-propis   as character no-undo .
define VARIABLE v-meneger            as character no-undo .
define VARIABLE v-manager-position   as character no-undo .
define VARIABLE v-fio-position       as character no-undo .
define VARIABLE v-num-print-prob     as character no-undo .
define VARIABLE v-time-income        as character no-undo .
define VARIABLE v-hour-income        as integer   no-undo .
define VARIABLE v-min-income         as integer   no-undo .
define variable v-DD-Month-YYYY      as character no-undo .
define variable v-DD-Month-YYYY-cert as character no-undo.
define variable v-condition          as character no-undo .
define variable v-inspection-cert    as character no-undo .
define variable v-seals              as character no-undo .
define variable v-seals-condition    as character no-undo .
define variable v-seals-condition-2  as character no-undo .
define variable v-date-cert          as character no-undo .
define variable v-nakl               as character no-undo .
define variable v-date               as character no-undo .
define variable v-car-vol            as integer   no-undo .
define variable v-mouth              as integer   no-undo .
define variable v-doc-not            as character no-undo .
define variable v-spisok-doc         as character no-undo .         
define variable v-attr-type          as character no-undo .
define variable v-komis              as logical   no-undo .    
define stream Out-Stream.
define stream OutStr-html.

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define VARIABLE v-attr-value        as character no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo .
define variable sgdkk               as logical   no-undo .
define variable v-msg               as character no-undo .
define variable v-kpsecs            as character no-undo .
define variable v-kpgds             as character no-undo .
define variable is-kp               as logical   no-undo .
define variable is-kprvs            as logical   no-undo .
define variable v-dec               as decimal   no-undo .
define variable v-sec-name          as character no-undo .
define variable varvalue            as character no-undo .
define variable v-ok                as logical   no-undo .

define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_goods         for ub.goods.
define buffer buf_place         for ub.place.
define buffer buf_c-place-attr  for ub.c-place-attr .
define buffer buf2_c-place-attr for ub.c-place-attr .
define buffer buf_rvs-line      for ub.rvs-line.
define buffer buf_rvs-doc       for ub.rvs-doc.
define buffer buf_clients       for ub.clients.
define buffer buf_firm          for ub.firm.
define buffer buf_shop          for ub.shop.
define buffer buf_doc-pl        for ub.doc-pl.
    
define TEMP-TABLE tt-petrol no-undo
  field date-TH       as character
  field num-TH        as character
  field type-AC       as character
  field num-AC        as character
  field name-gds      as character
  field vol-TH        as Decimal
  field density-TH    as decimal
  field temp-TH       as decimal
  field weight-TH     as decimal
  field urov-AC       as character
  field vol-AC        as decimal
  field density-AC    as decimal
  field temp-AC       as decimal
  field weight-AC     as decimal
  field passport      as character
  field passport-date as date
  field limit         as decimal
  field deficit       as decimal
  field excess        as decimal
  field weight-pri    as decimal
  field weight-est    as decimal
  field num-pl        as character
  field num-section   as integer
  field komis-priem   as logical
  index num-TH num-section passport type-AC num-AC .
        
define buffer buf_tt-petrol for tt-petrol .   

do
  on error undo, return error return-value
  :

  find first buf_trn-doc no-lock
    where recid( buf_trn-doc ) = rec_id.
  /*Общие данные*/
  
  /*Номер АЦ*/
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-car-num},OUTPUT v-car-num) no-error .
    
  /*Наличие СЭП*/
  find first ub.auto-tank-attr no-lock where ub.auto-tank-attr.auto-num = v-car-num and
    ub.auto-tank-attr.attr-code = "auto-sep" and
    logical(ub.auto-tank-attr.attr-value) = true no-error .
  if available ub.auto-tank-attr then sgdkk = true .
  
  v-InfoSectionsTotal = new InfoSectionsTotal().
  
  gdsecs_ :
  for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
     first buf_goods where buf_goods.artic = buf_doc-line.artic
       and buf_goods.prod-code = buf_doc-line.prod-code
       and buf_goods.prod-type = buf_doc-line.prod-type
  :
    
    v-InfoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_goods.gds-code).
    v-InfoSectionsTotal:GetDBAllAttr().
    do iNum = 1 to v-InfoSectionsTotal:SectionNum:
      v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum).
      if v-InfoSection:IsKP
      then do :
        is-kp = yes .
        if v-InfoSection:AccMeth = 1
        then do :
          is-kprvs = yes .
        end .
      end .
    end .
  end .
  
  v-kpsecs = "" .
  v-kpgds = "" .
  if is-kprvs
  then do :
    for each buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-after-doc}
                                   and buf_rvs-doc.out-code = buf_trn-doc.doc-code,
        each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code,
        first buf_goods where buf_goods.gds-code = buf_rvs-line.gds-code,
        first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
                                  and buf_place.obj-code = buf_rvs-doc.obj-code
                                  and buf_place.pl-code  = buf_rvs-line.pl-code
    :
      if buf_rvs-line.state-measure-cli-qnty = ?
      then do :
        if lookup(buf_place.loc1 + " " + buf_place.pl-name, v-kpsecs) > 0
        then next .
        v-kpsecs = v-kpsecs + buf_place.loc1 + " " + buf_place.pl-name + ", " .
        v-kpgds = v-kpgds + string(buf_goods.gds-code) + " " + buf_goods.gds-name + ", " .
      end .
    end .
  end .
  else if is-kp
  then do :
    gdsecs_ :
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
       first buf_goods where buf_goods.artic = buf_doc-line.artic
         and buf_goods.prod-code = buf_doc-line.prod-code
         and buf_goods.prod-type = buf_doc-line.prod-type
    :
      
      v-InfoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_goods.gds-code).
      v-InfoSectionsTotal:GetDBAllAttr().
      do iNum = 1 to v-InfoSectionsTotal:SectionNum:
        v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum).
        if (sgdkk and v-InfoSection:alarm-SGDKK and v-InfoSection:IsKP)
        or (not sgdkk)
        then do :
          v-dec = decimal(v-InfoSection:TankWeight) no-error .
          if error-status:error
          or v-dec = 0
          then do :
            v-kpsecs = v-kpsecs + v-InfoSection:SectionName + ", " .
            v-kpgds = v-kpgds + string(buf_goods.gds-code) + " " + buf_goods.gds-name + ", " .
          end .
        end .
      end .
    end .
  end .
  v-kpsecs = trim(v-kpsecs, ", ") .
  v-kpgds = trim(v-kpgds, ", ") .
  
  if v-kpsecs > ""
  and v-kpgds > ""
  then do :
    if is-kprvs
    then do :
      message "Не заполнены данные по замерам в резервуаре " + v-kpsecs +
              ". Не может быть определено принимаемое к учету количество " + v-kpgds +
              ". Печать Акта приема нефтепродуктов возможна только после определения количества принимаемого к учету по всем НП. Заполните данные по замерам в резервуаре " + v-kpsecs +
              "."
      view-as alert-box .
    end .
    else
    if is-kp
    then do :
      message "Не заполнены данные по замерам в секции " + v-kpsecs +
              ". Не может быть определено принимаемое к учету количество " + v-kpgds +
              ". Печать Акта приема нефтепродуктов возможна только после определения количества принимаемого к учету по всем НП. Заполните данные по замерам в секции " + v-kpsecs +
              "."
      view-as alert-box .
    end .
    return .
  end .
    
  /*Название объекта*/
  run clients-write(INPUT buf_trn-doc.obj-code,INPUT buf_trn-doc.obj-type,OUTPUT v-obj-name) no-error .    
  /*Адрес*/
  find first buf_shop no-lock where buf_shop.obj-code = buf_trn-doc.obj-code no-error .
  if AVAILABLE buf_shop then 
  do:
    v-obj-adress = buf_shop.addres1 .        
  end.    
        
    
  /*Название поставщика*/
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-ptbobj},OUTPUT v-attr-value) no-error .
  if v-attr-value <> "" then 
  do: 
    assign
      v-obj-code = integer (entry (2, v-attr-value, ";"))
      v-obj-type = entry (1, v-attr-value, ";")
      .
    run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-producer) no-error .
  end.
  else 
  do:
    assign
      v-obj-code = buf_trn-doc.cli-code
      v-obj-type = buf_trn-doc.cli-type
      .
    run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-producer) no-error .
  end.    
  /*Водитель-экспедитор*/
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-fio-driver},OUTPUT v-driver) no-error .

  /*Время прибытия*/                                        
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-time-income},OUTPUT v-time-income) no-error .
  v-hour-income = integer(substring(v-time-income, 1, 2)) no-error.
  v-min-income = integer(substring(v-time-income, 4, 2)) no-error.
  /*Техническое состояние*/
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-condition},OUTPUT v-condition) no-error .
  /*Пломбы от, дата свидетельства о поверке*/
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-date-cert},OUTPUT v-date-cert) no-error .
  if v-date-cert <> ? and v-date-cert <> "" then 
  do:
    run get-DD-month-YYYY(input v-date-cert, output v-DD-Month-YYYY-cert).
  end.
  else v-DD-Month-YYYY-cert = "".
  /*с №№№ свидетельство о поверке и их состояние*/
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-inspection-cert},OUTPUT v-inspection-cert) no-error .
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-seals-condition},OUTPUT v-seals) no-error .
  if v-seals <> "" then 
  do:
    assign
      v-seals-condition = entry (1, v-seals, {&delim-par}) .
    v-seals-condition-2 = entry (2, v-seals, {&delim-par}) no-error . 
  end.              
  /*Менеджер*/
  run person-write(INPUT buf_trn-doc.boss, OUTPUT v-meneger, output v-manager-position) no-error .
  /*Оператор*/
  run person-write(INPUT buf_trn-doc.wrkr, OUTPUT v-fio, output v-fio-position) no-error .
  /*Автопредприятие*/
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-autoent},OUTPUT v-attr-value) no-error .
  if v-attr-value <> "" then 
  do:
    assign
      v-obj-code = integer (entry (2, v-attr-value, ";"))
      v-obj-type = entry (1, v-attr-value, ";")
      .
    run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-carrier) no-error .
  end.
  /*Дата прописью*/
  run get-DD-month-YYYY(input buf_trn-doc.doc-date, output v-DD-Month-YYYY).
  /*Документы НЕ предоставленные*/    
  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-spisok-not-doc},OUTPUT v-attr-value) no-error .
  if v-attr-value = "" then v-doc-not = "ПРЕДОСТАВЛЕНЫ" .
  else 
  do:
    assign 
      v-doc-not    = "НЕ ПРЕДОСТАВЛЕНЫ" 
      v-spisok-doc = v-attr-value .
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
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<TR><TD colspan="10"></TD></TR>' skip
                            
    '<TR>' skip
    '<TD colspan="4" style="height: 14px; text-align: center;">' + v-obj-name + '</TD>' skip
    '<TD colspan="6" style="text-align: right;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="4" style="border-top: 1px solid black; text-align: center;">АЗС/АЗК</TD>' skip
    '<TD colspan="6" style="text-align: right;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="5" style=""></TD>' skip
    '<TD colspan="5" style="text-align: center;">УТВЕРЖДАЮ</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="5" style="height: 14px;"></TD>' skip
    '<TD colspan="5" style="text-align: center;">' + v-manager-position + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="5" style=""></TD>' skip
    '<TD colspan="5" style="text-align: center; border-top: 1px solid black;">Должность, Фамилия, И.О.</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="5" style="height: 14px;"></TD>' skip
    '<TD colspan="5" style="text-align: center;">' + v-meneger + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="5" style=""></TD>' skip
    '<TD colspan="5" style="text-align: center; border-top: 1px solid black;">руководителя АЗС/АЗК (председателя комиссии)</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="5" style=""></TD>' skip
    '<TD colspan="5" style="text-align: right;">' + string(v-DD-Month-YYYY) + '</TD>' skip
    '</TR>'skip

    '<TR><TD colspan="10" style="height: 14px;"></TD></TR>' skip
                            
    '<TR><TD colspan="10" style="font-weight: bold; text-align: center;">АКТ № ______ </TD></TR>' skip
                            
    '<TR><TD colspan="10" style="font-weight: bold; text-align: center;">приема нефтепродуктов в автомобильной цистерне</TD></TR>' skip
                            
    '<TR><TD colspan="10" style="font-weight: bold; text-align: center;">' + string(v-DD-Month-YYYY) + '</TD></TR>' skip
                    
    '<TR><TD colspan="10" style="height: 14px;"></TD></TR>' skip
                            
    '<TR>' skip
    '<TD colspan="10" style="">Составлен о том, что</TD>' skip
    '</TR>'skip
                    
    '<TR><TD colspan="10" style="height: 14px; text-align: center;">' + v-fio-position + '</TD></TR>' skip
                    
    '<TR><TD colspan="10" style="height: 14px; border-top: 1px solid black; text-align: center;">' + v-fio + '</TD></TR>' skip
                    
    '<TR><TD colspan="10" style="height: 14px; border-top: 1px solid black; text-align: center;">должность, фамилия, И.О., работника АЗС/АЗК (членов комиссии)</TD></TR>' skip
                    
    '<TR><TD colspan="10" style="height: 14px;"></TD></TR>' skip
                    
    '<TR>' skip
    '<TD colspan="3" style="">В присутствии водителя АЦ</TD>' skip
    '<TD colspan="7" style="text-align: center;">' + v-driver + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="3" style=""></TD>' skip
    '<TD colspan="7" style="border-top: 1px solid black; text-align: center;">Ф.И.О.</TD>' skip
    '</TR>'skip
                    
    '<TR><TD colspan="10" style="">провел(и) определение количества нефтепродуктов, прибывших в АЦ, и выявил следующее:</TD></TR>' skip
                    
    '<TR><TD colspan="10" style="height: 14px;"></TD></TR>' skip
                    
    '<TR>' skip
    '<TD colspan="3" style="">1. Наименование поставщика</TD>' skip
    '<TD colspan="7" style="text-align: center;">' + v-producer + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="3" style="height: 14px;"></TD>' skip
    '<TD colspan="7" style="border-top: 1px solid black; text-align: center;"></TD>' skip
    '</TR>'skip
                    
    /*        '<TR>' skip                                                                                                                 */
    /*        '<TD colspan="3" style="">2. Время прибытия АЦ</TD>' skip                                                                   */
    /*        '<TD colspan="7" style="text-align: center;">' + string(v-hour-income,"99") + ":" + string(v-min-income,"99") + '</TD>' skip*/
    /*        '</TR>'skip                                                                                                                 */
    /*                                                                                                                                    */
    /*        '<TR>' skip                                                                                                                 */
    /*        '<TD colspan="3" style="height: 14px;"></TD>' skip                                                                          */
    /*        '<TD colspan="7" style="border-top: 1px solid black; text-align: center;"></TD>' skip                                       */
    /*        '</TR>'skip                                                                                                                 */
                    
    '<TR>' skip
    '<TD colspan="3" style="">2. Техническое состояние АЦ</TD>' skip
    '<TD colspan="7" style="text-align: center;">' + v-condition + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="3" style=""></TD>' skip
    '<TD colspan="7" style="border-top: 1px solid black; text-align: center;">исправное, неисправное (с указанием конкретных замечаний)</TD>' skip
    '</TR>'skip
                    
    '<TR><TD colspan="10" style="height: 14px;"></TD></TR>' skip
                    
    /*        '<TR>' skip                                                                     */
    /*        '<TD colspan="10" style="">4. Пломбы от ' + v-DD-Month-YYYY-cert + ',</TD>' skip*/
    /*        '</TR>'skip                                                                     */
    /*                                                                                        */
    /*        '<TR><TD colspan="10" style="height: 14px;"></TD></TR>' skip                    */
    /*                                                                                        */
    '<TR>' skip
    '<TD colspan="3" style="">3. Пломбы от </TD>' skip
    '<TD colspan="7" style="border-bottom: 1px solid black;">' + v-DD-Month-YYYY-cert + '</TD>' skip
    '</TR>'skip

                    
    '<TR>' skip
    '<TD colspan="10" style="height: 14px;"></TD>' skip
    '</TR>'skip
        
    '<TR>' skip
    '<TD colspan="1" style="">С № </TD>' skip
    '<TD colspan="9" style="border-bottom: 1px solid black;">' + string(v-seals-condition) + '</TD>' skip
    '</TR>'skip
        
    '<TR>' skip
    '<TD colspan="10" style="height: 14px;"></TD>' skip
    '</TR>'skip
                            
    '<TR>' skip
    '<TD colspan="10" style="text-align: center;">' + string(v-seals-condition-2) + '</TD>' skip
    '</TR>'skip
        
    '<TR>' skip
    '<TD colspan="10" style="border-top: 1px solid black; text-align: center;">нарушены (не нарушены)</TD>' skip
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="10" style="height: 14px;"></TD>' skip
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="10" style="height: 14px;">4. Документы ' + v-doc-not + ' в полном комплекте и с соответствующими отметками.</TD>' skip
    '</TR>'skip                    
    .
  if v-doc-not = "НЕ ПРЕДОСТАВЛЕНЫ" then 
  do:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD colspan="10" style="height: 14px;">Не предоставлены: ' + v-spisok-doc + '</TD>' skip
      '</TR>'skip                    
      .
  end.
  put stream OutStr-html unformatted            
    /*        '<TR>' skip                                                                                                          */
    /*        '<TD colspan="8" style="text-align: center;">представлены (не представлены, указать недостающие документы)</TD>' skip*/
    /*        '<TD colspan="2" style=""></TD>' skip                                                                                */
    /*        '</TR>' skip                                                                                                         */
    '</thead>' skip
    '</table>' skip
                                                                             
    '<TABLE name="2"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 74px;"></td>' skip
    '<td style="width: 112px;"></td>' skip
    '<td style="width: 56px;"></td>' skip
    '<td style="width: 21px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 95px;"></td>' skip
    '<td style="width: 75px;"></td>' skip
    '<td style="width: 37px;"></td>' skip
    '<td style="width: 31px;"></td>' skip
    '<td style="width: 22px;"></td>' skip
    '<td style="width: 68px;"></td>' skip
    '<td style="width: 32px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 29px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '</tr>' skip
    .
                     
  put stream OutStr-html unformatted                         
    '<TR>' skip
    '<TD colspan="18" style="">5. При вскрытии АЦ и проверке количества нефтепродуктов установлено следующее:</TD>' skip
    '</TR>'skip

    '<TR><TD colspan="18" style="height: 14px;"></TD></TR>' skip
    '</thead>' skip
    '<tbody>' skip
    .



    /*Сбор данных*/

    /*По накладной*/
    /*Номер ТТН (ТН)*/
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
  if v-attr-value > "" then 
  do :
    assign 
      v-nakl = v-attr-value .
  end .
  else 
  do :
    assign 
      v-nakl = buf_trn-doc.doc-code .
  end.                    
    /*Дата ТТН (ТН)*/
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
  if v-attr-value > "" then v-date = v-attr-value.
  else 
  do :
    if integer(substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 1, 2)) > 12
      then v-date = string(date(buf_trn-doc.doc-date), "99/99/9999").
    else v-date = substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 4, 3)
        + substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 1, 3)
        + substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 7, 4).
  end.
    
  /*Тип АЦ - не известно*/
  for first ub.auto-tank no-lock where ub.auto-tank.auto-num = v-car-num:
    case ub.auto-tank.type-AC:
      when 1 then 
        do:
          v-car-type = "Бензовоз" .
        end.   
      when 2 then 
        do:
          v-car-type = "Газовоз" .
        end.  
    end case .   
  end.    
  if sgdkk then v-car-type = "СЭП" .   
  if v-car-type = "" then v-car-type = "Бензовоз" .
                                           
  next_:
  for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :  

    { str/is-petrl.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      is-petrolium
      is-pieces
      no-error
      }
    if error-status :error
      then 
    do:
      return error return-value .
    end.
    if is-petrolium then 
    do
      :
      find first buf_goods where buf_goods.artic = buf_doc-line.artic
        and buf_goods.prod-code = buf_doc-line.prod-code
        and buf_goods.prod-type = buf_doc-line.prod-type no-lock no-error.
      if AVAILABLE buf_goods then 
      do:
        assign
          v-doc-code = buf_trn-doc.doc-code
          .
        if buf_goods.engl-name = "" or buf_goods.engl-name = ? then v-gds-name = buf_goods.gds-name . 
        else v-gds-name = buf_goods.engl-name .
                
        run gds-attr-value in this-procedure
          (  input buf_goods.gds-code
          ,input {&attr-fuel-type}
          ,output v-attr-value
          ,output v-attr-type
          ) .
        if v-attr-value = "lgas" then 
        do:
          next next_  .
        end.
               
        v-InfoSectionsTotal:Initialization(v-doc-code, buf_goods.gds-code).
        v-InfoSectionsTotal:GetDBAllAttr().

        do iNum = 1 to v-InfoSectionsTotal:SectionNum:
          v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum) .
          assign
            v-num-prob       = v-InfoSection:Tests
            v-norm-doc       = v-InfoSection:NormDoc
            v-kol-prob       = v-InfoSection:KolProb
            v-tank-vol       = v-InfoSection:TankVol
            v-tank-density   = v-InfoSection:TankDensity 
            v-tank-weight    = v-InfoSection:TankWeight / 1000 
            v-tank-temp      = v-InfoSection:DensTemp
            v-date-prob      = v-InfoSection:DateProb
            v-hour-prob      = v-InfoSection:HourProb
            v-min-prob       = v-InfoSection:MinProb
            v-num-print-prob = v-InfoSection:NumPrintProb
            v-car-vol        = v-InfoSection:CarVol
            v-mouth          = v-InfoSection:Mouth
            .
          if v-komis <> yes then v-komis          = v-InfoSection:IsKP .       

          create tt-petrol .
          assign
            tt-petrol.num-TH      = v-nakl
            tt-petrol.date-TH     = v-date
            tt-petrol.num-AC      = v-car-num
            tt-petrol.type-AC     = v-car-type
            tt-petrol.num-section = v-InfoSectionsTotal:SectionNum
            .
          assign
            tt-petrol.name-gds   = v-gds-name
            tt-petrol.vol-TH     = decimal(v-InfoSection:DocQnty)
            tt-petrol.density-TH = decimal(v-InfoSection:DocDensity) * 1000
            tt-petrol.temp-TH    = decimal(v-InfoSection:TTNTemp)
            .
          tt-petrol.weight-TH   = tt-petrol.vol-TH  * tt-petrol.density-TH / 1000.
          if v-InfoSection:ABTarir <> 0 then 
          do: 
            tt-petrol.urov-AC = string(((v-InfoSection:ABTarir) * 100),"->>>>>>>>>>>9,99") .
          end.    
          else 
          do:
            tt-petrol.urov-AC = "по планку".
          end.    
          assign
            tt-petrol.vol-AC     = decimal(v-InfoSection:TankVol) / 1000
            tt-petrol.density-AC = decimal(v-InfoSection:TankDensity) * 1000
            tt-petrol.temp-AC    = decimal(v-InfoSection:DensTemp)
            tt-petrol.weight-AC  = decimal(v-InfoSection:TankWeight)
            tt-petrol.passport   = v-InfoSection:NumPassport
            .
            
          assign
            tt-petrol.limit      = v-InfoSection:AccAbsFact
            tt-petrol.weight-est = v-InfoSection:NaturalLoss
            tt-petrol.deficit    = v-InfoSection:Deficit
            tt-petrol.excess     = v-InfoSection:Excess
            tt-petrol.weight-pri = v-InfoSection:FactKgQnty
            tt-petrol.num-pl     = v-InfoSection:ListTank
            .  
          
          pl_ :
          for each buf_place no-lock where buf_place.obj-type = buf_doc-line.obj-type
                                       and buf_place.obj-code = buf_doc-line.obj-code
                                       and buf_place.loc1     = tt-petrol.num-pl :
            find first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                            and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                            and buf_doc-pl.out-code = buf_doc-line.doc-code
                                            and buf_doc-pl.gds-code = buf_goods.gds-code
                                            and buf_doc-pl.pl-code  = buf_place.pl-code
                                            no-error .
            if available buf_doc-pl
            then do :
              leave pl_ .
            end .
          end .
          
          find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = buf_place.obj-type
                                               and buf_c-place-attr.obj-code  = buf_place.obj-code
                                               and buf_c-place-attr.pl-code   = buf_place.pl-code
                                               and buf_c-place-attr.attr-code = {&place-com-tanks}
                                               and (buf_c-place-attr.corr-date < buf_trn-doc.fact-date
                                                 or buf_c-place-attr.corr-date = buf_trn-doc.fact-date and buf_c-place-attr.corr-time < buf_trn-doc.fact-time)
                                               no-error .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  tt-petrol.num-pl  = buf_place.loc1 + "," + buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input {&place-com-tanks}
                ,input buf_place.obj-code
                ,input buf_place.obj-type
                ,input buf_place.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if v-ok
              and varvalue > ""
              then do :
                assign
                  tt-petrol.num-pl  = buf_place.loc1 + "," + varvalue
                .
              end .
            end .
          end .
          else do :
            run placelib_get-attr  ( input {&place-com-tanks}
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
            if v-ok
            and varvalue > ""
            then do :
              assign
                tt-petrol.num-pl  = buf_place.loc1 + "," + varvalue
              .
            end .
          end .
            
          if sgdkk
          and not v-InfoSection:IsKP
          then do :
            tt-petrol.urov-AC = "SGDKK".
          end .
          
          if v-InfoSection:IsKP
          and v-InfoSection:AccMeth = 1
          then do :
            tt-petrol.urov-AC = "".
            tt-petrol.density-AC = ? .
            tt-petrol.temp-AC    = ? .
            tt-petrol.vol-AC     = decimal(v-InfoSection:TankVolPomiRvs) / 1000 .
            tt-petrol.weight-AC  = v-InfoSection:TankWeightRvs .
          end .
          

        /*                    for each buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type     */
        /*                        and buf_doc-pl.obj-code = buf_doc-line.obj-code                               */
        /*                        and buf_doc-pl.out-code = buf_doc-line.doc-code                               */
        /*                        and buf_doc-pl.gds-code = buf_goods.gds-code :                                */
        /*                        if tt-petrol.num-pl = "" then                                                 */
        /*                        do:                                                                           */
        /*                            tt-petrol.num-pl = string(buf_doc-pl.pl-code) .                           */
        /*                        end.                                                                          */
        /*                        else                                                                          */
        /*                        do:                                                                           */
        /*                            assign                                                                    */
        /*                                tt-petrol.num-pl = tt-petrol.num-pl + "," + string(buf_doc-pl.pl-code)*/
        /*                                .                                                                     */
        /*                        end.                                                                          */
        /*                                                                                                      */
        /*                    end.                                                                              */
 
        end.

      end.    /*      if is-petrolium        */
    end.    /*        for each buf_doc-line     */

  end.
  run print-table1 no-error .
                                        
  run print-table2 no-error .
                        
  put stream OutStr-html unformatted    
    '</tbody>' skip
    '<tfoot>' skip
                    
    '<TR><TD colspan="18" style="height: 14px;"></TD></TR>' skip
                    
    '<TR><TD colspan="18" style="font-style: italic;">Примечания:</TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="18" style="font-style: italic;">1 - используется расчётное значение, является информационным</TD></TR>' skip
        
    '<TR><TD text_wrap="true" colspan="18" style="font-style: italic;">2 - указывается с обозначением метода определения плотности у поставщика</TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="18" style="font-style: italic;">3 - указывается - "по планку", или величина отклонения уровня от планки со знаком "+" если фактический уровень нефтепродукта выше планки, и "-", если ниже. Если горловина отсутствует (планка находится вне горловины) - указываются только знаки - "+" или "-"</TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="18" style="font-style: italic;">Записи в таблице делаются построчно для каждой группы (подгруппы, марки) нефтепродукта. Построчно делаются записи и для одной марки нефтепродукта, если при его приеме происходит смена приемного резервуара.</TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="18" style="font-style: italic;">При приеме на АЗС/АЗК АЦ, оборудованных СЭП, в случае, если при распечатке чек-отчета СЭП не выявлено инцидентом в пути следования нефтепродукта, графы 9-13, 15-17 не заполняются, в графе 18 указывается значение, соответствующее значению, указанному в графе 8.</TD></TR>' skip
                    
    '<TR><TD colspan="18" style="height: 14px;"></TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="18" style="">6. Прилагаемые к акту документы ________________________________________________________________________</TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="18" style="">7. Время: начала приема ____ ч ______ мин</TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="18" style="">          окончания приема ____ ч ______ мин.</TD></TR>' skip
                    
    '<TR><TD colspan="18" style="height: 14px;"></TD></TR>' skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style="">Подпись (и)</TD>' skip
    '<TD colspan="7" style="text-align: center;">' + v-fio-position + " " + v-fio + '</TD>'
    '<TD colspan="6"></TD>'
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style=""></TD>' skip
    '<TD colspan="7" style="border-top: 1px solid black;">должность, Ф.И.О. работника АЗС/АЗК (членов комиссии)</TD>'
    '<TD colspan="6"></TD>'
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style="height: 14px;"></TD>' skip
    '<TD colspan="7" style="text-align: center;">' + v-driver + '</TD>'
    '<TD colspan="6"></TD>'
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style=""></TD>' skip
    '<TD colspan="7" style="border-top: 1px solid black;">должность, Ф.И.О. водителя АЦ</TD>'
    '<TD colspan="6"></TD>'
    '</TR>'skip
    .
  if v-komis = yes then 
  do:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD colspan="3"></TD>'
      '<TD colspan="2" style="">Состав комиссии:</TD>' skip
      '<TD colspan="7" style="text-align: center;"></TD>'
      '<TD colspan="6"></TD>'
      '</TR>'skip
                    
      '<TR>' skip
      '<TD colspan="3"></TD>'
      '<TD colspan="2" style="height: 14px;"></TD>' skip
      '<TD colspan="7" style="border-top: 1px solid black;"></TD>'
      '<TD colspan="6"></TD>'
      '</TR>'skip
                    
      '<TR>' skip
      '<TD colspan="3"></TD>'
      '<TD colspan="2" style="height: 14px;"></TD>' skip
      '<TD colspan="7" style="text-align: center;"></TD>'
      '<TD colspan="6"></TD>'
      '</TR>'skip
                    
      '<TR>' skip
      '<TD colspan="3"></TD>'
      '<TD colspan="2" style="height: 14px;"></TD>' skip
      '<TD colspan="7" style="border-top: 1px solid black;"></TD>'
      '<TD colspan="6"></TD>'
      '</TR>'skip
        
      '<TR>' skip
      '<TD colspan="3"></TD>'
      '<TD colspan="2" style="height: 14px;"></TD>' skip
      '<TD colspan="7" style="text-align: center;"></TD>'
      '<TD colspan="6"></TD>'
      '</TR>'skip
                    
      '<TR>' skip
      '<TD colspan="3"></TD>'
      '<TD colspan="2" style="height: 14px;"></TD>' skip
      '<TD colspan="7" style="border-top: 1px solid black;"></TD>'
      '<TD colspan="6"></TD>'
      '</TR>'skip
      .
                
  end.  
          
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
                            
  output stream OutStr-html close.     
                                                                                                                
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).
end.

/* **********************  Internal Procedures  *********************** */
procedure doc-attr-write:
    
  DEFINE input PARAMETER   p-doc-code      as character    no-undo .
  DEFINE INPUT PARAMETER   p-attr-code     as character    no-undo .
  DEFINE OUTPUT PARAMETER  p-attr-value    as character    no-undo .
        
  find first buf_doc-attr no-lock where buf_doc-attr.doc-code = p-doc-code
    and buf_doc-attr.attr-code = p-attr-code no-error .
  if AVAILABLE buf_doc-attr then 
  do:
    p-attr-value = buf_doc-attr.attr-value .
  end.       
                                          
end.    

procedure person-write:
    
  DEFINE input PARAMETER   p-obj-code      as integer      no-undo .
  DEFINE OUTPUT PARAMETER  p-obj-name      as character    no-undo .
  define OUTPUT PARAMETER  p-position      as CHARACTER       NO-UNDO .
  define variable v-name as character no-undo . 
  define buffer buf_person for ub.person .    
  find first buf_person no-lock where buf_person.psn-code = p-obj-code no-error .
  if AVAILABLE buf_person then 
  do:
    run rep/get-psn.p(input buf_person.psn-code, output v-name ).
    p-obj-name = v-name + '  ' + buf_person.name1 + ' ':U + buf_person.name2.
    p-position = buf_person.position .
        
  end.       
                                          
end. 


procedure clients-write:
    
  DEFINE input PARAMETER   p-obj-code      as integer      no-undo .
  DEFINE INPUT PARAMETER   p-obj-type      as character    no-undo .
  DEFINE OUTPUT PARAMETER  p-obj-name      as character    no-undo .
        
  find first buf_clients no-lock where buf_clients.obj-code = p-obj-code
    and buf_clients.obj-type = p-obj-type no-error .
  if AVAILABLE buf_clients then 
  do:
    p-obj-name = buf_clients.obj-name .
  end.     
                                            
end. 


PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

procedure get-DD-Month-YYYY:
    
  /* Получение даты в формате "01 Января 2014г." */
  define input parameter p-dat-date as date no-undo.
  define output parameter p-str-date as character no-undo.

  define variable v-str-date  as character no-undo.
  define variable v-str-day   as character no-undo.
  define variable v-num-month as character no-undo.
  define variable v-str-month as character no-undo.
  define variable v-str-year  as character no-undo.

  v-str-date = string(p-dat-date).

  do: /* Получаем день в формате цифры, вида NN. */
    v-str-day = string(entry(1, v-str-date, "/")).
  end. /* Получаем день в формате цифры, вида NN. */

  do: /* Получаем прописью месяц */
    v-num-month = entry(2, v-str-date, "/").
    v-str-month = MonthNameRusCase(integer(v-num-month), 2).

  end. /* Получаем прописью месяц */

  do: /* Получаем год в формате цифры, вида "NNNN" */
    /*        v-str-year = entry(3, v-str-date, "/").*/
    v-str-year = string(year(p-dat-date)).
  end. /* Получаем год в формате цифры, вида "NNNN" */

  /* Получаем цифро-буквенную дату в одной строке */
  p-str-date = '" ' + v-str-day + ' "' + " " + v-str-month + " " + v-str-year + " г.".

end procedure.


procedure print-table1:
    
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Дата и номер ТТН (ТН)</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Тип АЦ</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Номер АЦ</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Наименование нефтепродуктов</TD>' skip
    '<TD text_wrap="true" colspan="5" style="text-align: center;">Показатели по ТТН (ТН)</TD>' skip
    '<TD text_wrap="true" colspan="9" style="text-align: center;">Результаты измерений в АЦ/приемном резервуаре</TD>' skip
    '</TR>'skip       
                    
    '<TR style="height: 20px;">' skip
    '<TD text_wrap="true" style="text-align: center;">объем (1), л</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">плотность (2), кг/м3</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">температура,С </TD>' skip
    '<TD text_wrap="true" style="text-align: center;">масса, кг</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center; height: 25px;">фактический уровень наполнения (3), мм</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">объем, м3</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">плотность, кг/м3</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">температура,С </TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">масса, кг</TD>' skip
    '</TR>'skip   

    '<TR>' skip
    '<TD style="text-align: center;">1</TD>' skip
    '<TD style="text-align: center;">2</TD>' skip
    '<TD style="text-align: center;">3</TD>' skip
    '<TD style="text-align: center;">4</TD>' skip
    '<TD style="text-align: center;">5</TD>' skip
    '<TD colspan="2" style="text-align: center;">6</TD>' skip
    '<TD style="text-align: center;">7</TD>' skip
    '<TD style="text-align: center;">8</TD>' skip
    '<TD colspan="2" style="text-align: center;">9</TD>' skip
    '<TD colspan="2" style="text-align: center;">10</TD>' skip
    '<TD colspan="2" style="text-align: center;">11</TD>' skip
    '<TD style="text-align: center;">12</TD>' skip
    '<TD colspan="2"  style="text-align: center;">13</TD>' skip
    '</TR>'skip     
    .
  for each tt-petrol:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-petrol.num-TH) + " " + string(tt-petrol.date-TH) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-petrol.type-AC) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-petrol.num-AC) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + if tt-petrol.name-gds <> ? then string(tt-petrol.name-gds) + '</TD>' else " "  + '</TD>' skip
      '<TD text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-petrol.vol-TH,"->>>>>>>>>>>9",0) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.vol-TH,"->>>>>>>>>>>9",0) + '</TD>' skip
      '<TD text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.density-TH,"->>>>>>>>>>>9.9",1) + '" colspan="2" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.density-TH,"->>>>>>>>>>>9.9",1) + '</TD>' skip        
      '<TD text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.temp-TH,"->>>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.temp-TH,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.weight-TH,"->>>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.weight-TH,"->>>>>>>>>>>9.9",1) + '</TD>' skip
    . 
    if tt-petrol.urov-AC = "SGDKK"
    then do :
      put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="2" style="text-align: center;"> </TD>' skip
      '<TD colspan="2";></TD>' skip
      '<TD colspan="2";></TD>' skip        
      '<TD></TD>' skip
      '<TD colspan="2";></TD>' skip
      '</TR>'skip     
      .
    end .
    else do : 
      put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="2" style="text-align: center;">' + tt-petrol.urov-AC + '</TD>' skip
      '<TD text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.vol-AC,"->>>>>>>>>>>9.999",3) + '" colspan="2"  style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.vol-AC,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.density-AC,"->>>>>>>>>>>9.9",1) + '" colspan="2"  style="text-align: center;">' + (if tt-petrol.density-AC = ? then " " else fnc-convert-dot-to-colon(tt-petrol.density-AC,"->>>>>>>>>>>9.9",1)) + '</TD>' skip        
      '<TD text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.temp-AC,"->>>>>>>>>>>9.9",1) + '" style="text-align: center;">' + (if tt-petrol.temp-AC = ? then " " else fnc-convert-dot-to-colon(tt-petrol.temp-AC,"->>>>>>>>>>>9.9",1)) + '</TD>' skip
      '<TD text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.weight-AC,"->>>>>>>>>>>9.9",1) + '" colspan="2"  style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.weight-AC,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '</TR>'skip     
      .
    end .
  end.
end procedure .

procedure print-table2:
    
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<thead>' skip
    '<TR><TD colspan="18" style="height: 14px;"></TD></TR>' skip
    '<TR><TD colspan="18" style="height: 14px;"></TD></TR>' skip
    '</thead>' skip
    '<tbody>' skip
    '<TR style="height: 20px;">' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Дата и номер ТТН (ТН)</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Тип АЦ</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Номер АЦ</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Наименование нефтепродуктов</TD>' skip
    '<TD text_wrap="true" rowspan="2" colspan="2" style="text-align: center;">Паспорт (№, Дата)</TD>' skip
    '<TD text_wrap="true" colspan="6" style="text-align: center; height: 20px;">Расхождения между количеством нефтепродукта, указанным в накладной и полученным по результатам измерений при приеме</TD>' skip
    '<TD text_wrap="true" rowspan="2" colspan="2" style="text-align: center;">Масса, подлежащая оприходованию, кг</TD>' skip
    '<TD text_wrap="true" rowspan="2" colspan="2" style="text-align: center;">Масса естественной убыли, кг</TD>' skip
    '<TD text_wrap="true" rowspan="2" colspan="2" style="text-align: center;">№ резервуара, в который проведен слив</TD>' skip
    '</TR>'skip       
                    
    '<TR>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">в пределах допускаемых расхождений, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">недостача, кг</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">излишки, кг</TD>' skip
    '</TR>'skip   

    '<TR>' skip
    '<TD style="text-align: center;">1</TD>' skip
    '<TD style="text-align: center;">2</TD>' skip
    '<TD style="text-align: center;">3</TD>' skip
    '<TD style="text-align: center;">4</TD>' skip
    '<TD colspan="2" style="text-align: center;">14</TD>' skip
    '<TD colspan="3" style="text-align: center;">15</TD>' skip
    '<TD style="text-align: center;">16</TD>' skip
    '<TD colspan="2" style="text-align: center;">17</TD>' skip
    '<TD colspan="2" style="text-align: center;">18</TD>' skip
    '<TD colspan="2" style="text-align: center;">19</TD>' skip
    '<TD colspan="2" style="text-align: center;">21</TD>' skip
    '</TR>'skip     
    .
  for each tt-petrol:
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + tt-petrol.num-TH + " " + tt-petrol.date-TH + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-petrol.type-AC) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + tt-petrol.num-AC + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + tt-petrol.name-gds + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center;">' + tt-petrol.passport + '</TD>' skip
    .
    if tt-petrol.urov-AC = "SGDKK"
    then do :
      put stream OutStr-html unformatted
      '<TD colspan="3";></TD>' skip
      '<TD></TD>' skip
      '<TD colspan="2";></TD>' skip           
      .
    end .
    else do :
      put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="3" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.limit,"->>>>>>>>>>9.9",1) + '" style="text-align: center;">' + (if tt-petrol.limit = ? then " " else fnc-convert-dot-to-colon(tt-petrol.limit,"->>>>>>>>>>9.9",1)) + '</TD>' skip
      '<TD text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.deficit,"->>>>>>>>>>9.9",1) + '" style="text-align: center;">' + (if tt-petrol.limit = ? then " " else fnc-convert-dot-to-colon(tt-petrol.deficit,"->>>>>>>>>>9.9",1)) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.excess,"->>>>>>>>>>9.9",1) + '" style="text-align: center;">' + (if tt-petrol.limit = ? then " " else fnc-convert-dot-to-colon(tt-petrol.excess,"->>>>>>>>>>9.9",1)) + '</TD>' skip           
      .
    end .
    put stream OutStr-html unformatted
      '<TD text_wrap="true" colspan="2" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.weight-pri,"->>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.weight-pri,"->>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.weight-est,"->>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.weight-est,"->>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD text_wrap="true" colspan="2" style="text-align: center;">' + tt-petrol.num-pl + '</TD>' skip
      '</TR>'skip     
      .
  end.
     
end procedure .

