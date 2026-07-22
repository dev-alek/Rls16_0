/*

$Revision: 8ee12a69ba68, 1075, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:37:43 2017 +0300 $
$Workfile: akt-prob.p $
$Archive: rep/akt-prob.p $

Акт отбора проб нефтепродуктов

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.str.*.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: 8ee12a69ba68, 1075, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:37:43 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: akt-prob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/akt-prob.p $":U .
define variable vss-description as character no-undo init "Акт отбора проб нефтепродуктов".
{ cmp/vssrevis.i }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U

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

define variable is-petrolium        as logical   no-undo.
define variable is-pieces           as logical   no-undo.
define variable v-doc-code          like ub.trn-doc.doc-code no-undo .
define variable v-gds-code          like ub.goods.gds-code no-undo .
define variable v-fio               as character no-undo .
define variable v-InfoSectionsTotal as class     InfoSectionsTotal no-undo .
define variable iNum                as integer   no-undo .
define variable jj                  as integer   no-undo .
define variable v-producer          as character no-undo .
define variable v-obj-name          as character no-undo .
define variable v-driver            as character no-undo .       
define variable v-num-car           as character no-undo .          
define VARIABLE v-gds-name          as character no-undo .        
define VARIABLE v-num-prob          as character no-undo .
DEFINE VARIABLE v-norm-doc          as character no-undo .
define VARIABLE v-kol-prob          as decimal   no-undo .
define VARIABLE v-tank-vol          as decimal   no-undo .
DEFINE VARIABLE v-tank-density      as DECIMAL   no-undo .
define VARIABLE v-tank-weight       as decimal   no-undo .
define variable v-tank-temp         as decimal   no-undo .
define variable v-date-prob         as date      no-undo .
define variable v-ship-date         as date      no-undo .
define variable v-hour-prob         as integer   no-undo .
define variable v-min-prob          as integer   no-undo .
define VARIABLE v-obj-adress        as character no-undo .
define VARIABLE v-carrier           as character no-undo .
define variable v-date-prob-propis  as character no-undo .
define VARIABLE v-meneger           as character no-undo .
define VARIABLE v-num-print-prob    as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define VARIABLE v-attr-value        as character no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo .

define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_goods         for ub.goods.
define buffer buf_rvs-line      for ub.rvs-line.
define buffer buf_rvs-doc       for ub.rvs-doc.
define buffer buf_clients       for ub.clients.
define buffer buf_firm          for ub.firm.
define buffer buf_shop          for ub.shop.
    
do
    on error undo, return error return-value
    :

    find first buf_trn-doc no-lock
        where recid( buf_trn-doc ) = rec_id.
    /*Общие данные*/
    
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
    if v-attr-value <> "" then do: 
    assign
        v-obj-code = integer (entry (2, v-attr-value, ";"))
        v-obj-type = entry (1, v-attr-value, ";")
        .
    run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-producer) no-error .
    end.
    /*Водитель-экспедитор*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-fio-driver},OUTPUT v-driver) no-error .
    /*Гос номер авто*/                                        
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-car-num},OUTPUT v-num-car) no-error .
    /*Менеджер*/
    run person-write(INPUT buf_trn-doc.boss, OUTPUT v-meneger) no-error .
    /*Оператор*/
    run person-write(INPUT buf_trn-doc.wrkr, OUTPUT v-fio) no-error .
    /*Автопредприятие*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-autoent},OUTPUT v-attr-value) no-error .
    if v-attr-value <> "" then do:
    assign
        v-obj-code = integer (entry (2, v-attr-value, ";"))
        v-obj-type = entry (1, v-attr-value, ";")
        .
    run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-carrier) no-error .
    end.

    v-ship-date = buf_trn-doc.shift-date .

    v-InfoSectionsTotal = new InfoSectionsTotal().

    for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code :  

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
                    v-gds-name = buf_goods.engl-name

                    .
                /* атрибут Номер приходной накладной */
                define var v-type as character no-undo .
                { str/tdat-val.i
                  buf_trn-doc.doc-code
                  {&trdcattr-nids}
                  v-doc-code-attr
                  v-type
                  no-error
                } 
                   
                v-InfoSectionsTotal:Initialization(v-doc-code, buf_goods.gds-code).
                v-InfoSectionsTotal:GetDBAllAttr().
                v-date-prob      = v-InfoSectionsTotal:GetInfoSectionProp(1):DateProb .
                v-date-prob-propis =  '" '  + string(day(v-date-prob))
                    + ' " ' + entry(month(v-date-prob), {&month-list-for-date})
                    + " " + string(year(v-date-prob), "9999") + " г." .

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
                    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
                    '<thead>' skip
                    .
                put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '<td style="width: 31px;"></td>' skip
                    '</tr>' skip
                    .
                        
 
                put stream OutStr-html unformatted
                    '<TR><TD colspan="21"></TD></TR>' skip
                            
                    '<TR>' skip
                    '<TD colspan="16" style=""></TD>' skip
                    '<TD colspan="4" style="text-align: right;">Приложение №2</TD>' skip
                    '<TD style=""></TD>' skip
                    '</TR>'skip

                    '<TR>' skip
                    '<TD colspan="11" style=""></TD>' skip
                    '<TD colspan="9" style="text-align: right;">к Приказу № 762-02/1 от "24" ноября 2008г.</TD>' skip
                    '<TD style=""></TD>' skip
                    '</TR>'skip

                    '<TR><TD colspan="21" style="height: 14px;"></TD></TR>' skip
                            
                    '<TR><TD colspan="21" style="font-weight: bold; text-align: center;">АКТ</TD></TR>' skip
                            
                    '<TR><TD colspan="21" style="font-weight: bold; text-align: center;">отбора проб нефтепродуктов</TD></TR>' skip
                            
                    '<TR><TD colspan="21" style="height: 14px;"></TD></TR>' skip
                            
                    '<TR>' skip
                    '<TD colspan="3" style="">на АЗК/АЗС №</TD>' skip
                    '<TD colspan="5" style="border-bottom: 1px solid black; text-align: center;">' + v-obj-name + '</TD>' skip
                    '<TD></TD>'
                    '<TD colspan="11" style="">' + v-obj-adress + '</TD>' skip
                    '<TD></TD>'
                    '</TR>'skip

                    '<TR>' skip
                    '<TD colspan="9" style=""></TD>' skip
                    '<TD colspan="12" style="text-align: center; font-size: 10px; text-valign: top; border-top: 1px solid black;">(адрес)</TD>' skip
                    '</TR>'skip

                    '<TR><TD colspan="21" style="text-align: center;">от ' + v-date-prob-propis + '</TD></TR>' skip

                    '<TR><TD colspan="21" style="height: 14px;"></TD></TR>' skip
                            
                    '<TR>' skip
                    '<TD></TD>'
                    '<TD colspan="8" style="text-align: right;">Комиссия в составе председателя</TD>' skip
                    '<TD colspan="11" style="border-bottom: 1px solid black; text-align: center;">' + v-meneger + '</TD>' skip
                    '<TD></TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="9" style=""></TD>' skip
                    '<TD colspan="12" style="text-align: center; font-size: 10px; text-valign: top;">(управляющий АЗК/АЗС/старший оператор АЗК/АЗС, Ф.И.О.)</TD>' skip
                    '</TR>'skip
                                                        
                    '<TR>' skip
                    '<TD colspan="4" style="">и членов комиссии</TD>' skip
                    '<TD></TD>'
                    '<TD colspan="14" style="text-align: center;">' + v-fio + '</TD>' skip
                    '<TD></TD>'
                    '<TD></TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="4" style=""></TD>' skip
                    '<TD colspan="17" style="border-top: 1px solid black; text-align: center; font-size: 10px; text-valign: top;">(старший оператор АЗК/АЗС/ оператор АЗК/АЗС, Ф.И.О.)</TD>' skip
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="10" style="">в присутствии представителя Перевозчика</TD>' skip
                    '<TD colspan="6" style="text-align: center;">' + v-carrier + '</TD>'
                    '<TD colspan="5" style="text-align: center;">' + v-driver + '</TD>' skip
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="9" style=""></TD>' skip
                    '<TD colspan="12" style="border-top: 1px solid black; text-align: center; font-size: 10px; text-valign: top;">(Наименование предприятия - перевозчика, Ф.И.О. водителя - экпедитора)</TD>' skip
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD style="">от</TD>' skip
                    '<TD></TD>'
                    '<TD colspan="6" style="text-align: center;">' + v-date-prob-propis + '</TD>' skip
                    '<TD></TD>'
                    '<TD></TD>'
                    '<TD colspan="11" style="text-align: center;">произвела отбор проб нефтепродуктов согласно</TD>' skip
                    '</TR>'skip

                    '<TR><TD colspan="21">следующему перечню:</TD></TR>' skip
                            
                    '</thead>' skip
                    '<tbody>' skip
                    .
                put stream OutStr-html unformatted
                    '<TR style="height: 122px; vertical-align: top;">' skip
                    '<TD text_wrap="true" colspan="2" style="text-align: center; vertical-align: top;">Номер пробы</TD>' skip
                    '<TD text_wrap="true" colspan="3" style="text-align: center; vertical-align: top;">Наименование НП</TD>' skip
                    '<TD text_wrap="true" colspan="3" style="text-align: center; vertical-align: top;">Место отбора пробы (резервуар АЗК/АЗС, Транспортное средство)</TD>' skip
                    '<TD text_wrap="true" colspan="3" style="text-align: center; vertical-align: top;">Кол-во отобраной пробы, л</TD>' skip
                    '<TD text_wrap="true" colspan="3" style="text-align: center; vertical-align: top;">Кол-во НП, от которого отобрана проба, т</TD>' skip
                    '<TD text_wrap="true" colspan="3" style="text-align: center; vertical-align: top;">Вид анализа (Приемо-сдаточный, контрольный, полный, арбитражный)</TD>' skip
                    '<TD text_wrap="true" colspan="4" style="text-align: center; vertical-align: top;">Наименование поставщика и дата отгрузки</TD>' skip
                    '</TR>'skip       
                    .
                            
                do iNum = 1 to v-InfoSectionsTotal:SectionNum:
                    if v-InfoSectionsTotal:GetInfoSectionProp(iNum):Tests <> "" and v-InfoSectionsTotal:GetInfoSectionProp(iNum):Tests <> ? then 
                    do:
                        assign
                            v-num-prob     = v-InfoSectionsTotal:GetInfoSectionProp(iNum):Tests
                            v-norm-doc     = v-InfoSectionsTotal:GetInfoSectionProp(iNum):NormDoc
                            v-kol-prob     = v-InfoSectionsTotal:GetInfoSectionProp(iNum):KolProb
                            v-tank-vol     = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankVol
                            v-tank-density = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankDensity 
                            v-tank-weight  =  v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankWeight / 1000 
                            v-tank-temp      = v-InfoSectionsTotal:GetInfoSectionProp(iNum):DensTemp
                            v-date-prob      = v-InfoSectionsTotal:GetInfoSectionProp(iNum):DateProb
                            v-hour-prob      = v-InfoSectionsTotal:GetInfoSectionProp(iNum):HourProb
                            v-min-prob       = v-InfoSectionsTotal:GetInfoSectionProp(iNum):MinProb
                            v-num-print-prob = v-InfoSectionsTotal:GetInfoSectionProp(iNum):NumPrintProb
                            .
                        v-date-prob-propis = "".

                        put stream OutStr-html unformatted
                            '<TR style="height: 70px; vertical-align: top;">' skip
                            '<TD text_wrap="true" colspan="2" style="text-align: center;">' + v-num-prob + '</TD>' skip
                            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + v-gds-name + '</TD>' skip
                            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + v-num-car + '</TD>' skip
                            '<TD val="' + fnc-convert-dot-to-colon(v-kol-prob,"->>>>>>>>>>>9.99",2) + '" colspan="3" style="text-align: center;">' + fnc-convert-dot-to-colon(v-kol-prob,"->>>>>>>>>>>9.99",2) + '</TD>' skip
                            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-tank-weight,"->>>>>>>>>>>9.999",3) + '" colspan="3" style="text-align: center;">' + fnc-convert-dot-to-colon(v-tank-weight,"->>>>>>>>>>>9.99",3) + '</TD>' skip
                            '<TD text_wrap="true" colspan="3" style="text-align: center;">приемо-сдаточный</TD>' skip
                            '<TD text_wrap="true" colspan="4" style="text-align: center;">' + v-producer + " " + if string(v-ship-date) <> ? then string(v-ship-date,"99/99/9999") else "01/01/1900" + '</TD>' skip
                            '</TR>'skip                       
                            .     
                    end.
                end.
                put stream OutStr-html unformatted
                    '</tbody>' skip
                    '<tfoot>' skip
                            
                    '<TR><TD colspan="21">Пробы отобраны (отметить нужное):</TD></TR>' skip
                    '<TR><TD colspan="21"> - согласно ГОСТ 2517-1012 (для мер вместимости, полной вместимости и др.)</TD></TR>' skip
                    '<TR><TD colspan="21"> - согласно Инструкции по контролю и обеспечению сохранения качеств нефтепродуктов</TD></TR>' skip
                    '<TR><TD colspan="21">   в организациях нефтепродуктообеспечения (утверждена Приказом Министерства</TD></TR>' skip
                    '<TR><TD colspan="21">   энергетики России от 19 июня 2003 г. №231) (для ТРК)</TD></TR>' skip
                    '<TR><TD colspan="21">в чистую, сухую посуду и опечатаны печатью с оттиском</TD></TR>' skip
                            
                    '<TR>' skip
                    '<TD colspan="4" style="text-align: center; border-bottom: 1px solid black;">' + v-num-print-prob + '</TD>' skip
                    '<TD></TD>'
                    '<TD colspan="11" style="">Пробы отобраны для анализа в лаборатории</TD>' skip
                    '<TD></TD>'
                    '<TD colspan="4" style="border-bottom: 1px solid black; text-align: center;"></TD>' skip
                    '</TR>'skip                            
                            
                    '<TR>' skip
                    '<TD colspan="4" style="border-top: 1pxsolid black; text-align: center; font-size: 10px; text-valign: top;">(плашка оттиска)</TD>' skip
                    '<TD colspan="17" style=""></TD>' skip
                    '</TR>'skip                            
                            
                    '<TR><TD colspan="21" style="height: 14px;"></TD></TR>' skip
                            
                    '<TR>' skip
                    '<TD colspan="5" style="">Председатель комиссии</TD>' skip
                    '<TD colspan="4" style="border-bottom: 1px solid black; text-align: center;"></TD>' skip
                    '<TD style="text-align: right;">(</TD>'
                    '<TD colspan="4" style="border-bottom: 1px solid black; text-align: center;">' + v-meneger + '</TD>' skip
                    '<TD style="">)</TD>'
                    '<TD colspan="4" style=""></TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="5" style=""></TD>' skip
                    '<TD colspan="4" style="text-align: center;"></TD>' skip
                    '<TD style="text-align: right;"></TD>'
                    '<TD colspan="4" style="text-align: center; text-valign: top; font-size: 10px;">Ф.И.О.</TD>' skip
                    '<TD colspan="5" style=""></TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="5" style="">Члены комиссии</TD>' skip
                    '<TD colspan="4" style="border-bottom: 1px solid black; text-align: center;"></TD>' skip
                    '<TD style="text-align: right;">(</TD>'
                    '<TD colspan="4" style="border-bottom: 1px solid black; text-align: center;">' + v-fio + '</TD>' skip
                    '<TD style="">)</TD>'
                    '<TD colspan="4" style=""></TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="5" style=""></TD>' skip
                    '<TD colspan="4" style="text-align: center; text-valign: top; font-size: 10px;">подпись</TD>' skip
                    '<TD style="text-align: right;"></TD>'
                    '<TD colspan="4" style="text-align: center; text-valign: top; font-size: 10px;">Ф.И.О.</TD>' skip
                    '<TD colspan="5" style=""></TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="5" style=""></TD>' skip
                    '<TD colspan="4" style="border-bottom: 1px solid black; text-align: center;"></TD>' skip
                    '<TD style="text-align: right;">(</TD>'
                    '<TD colspan="4" style="border-bottom: 1px solid black; text-align: center;"></TD>' skip
                    '<TD style="">)</TD>'
                    '<TD colspan="4" style=""></TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="5" style=""></TD>' skip
                    '<TD colspan="4" style="text-align: center; text-valign: top; font-size: 10px;">подпись</TD>' skip
                    '<TD style="text-align: right;"></TD>'
                    '<TD colspan="4" style="text-align: center; text-valign: top; font-size: 10px;">Ф.И.О.</TD>' skip
                    '<TD colspan="5" style=""></TD>'
                    '</TR>'skip                            
                            
                    '<TR>' skip
                    '<TD colspan="11" style="">Представитель Перевозчика (водитель-экспедитор)</TD>' skip
                    '<TD colspan="3" style="border-bottom: 1px solid black; text-align: center;"></TD>' skip
                    '<TD style="text-align: right;">(</TD>'
                    '<TD colspan="5" style="border-bottom: 1px solid black; text-align: center;">' + v-driver + '</TD>' skip
                    '<TD style="">)</TD>'
                    '</TR>'skip
                            
                    '<TR>' skip
                    '<TD colspan="11" style=""></TD>' skip
                    '<TD colspan="3" style="text-align: center; text-valign: top; font-size: 10px;">подпись</TD>' skip
                    '<TD style="text-align: right;"></TD>'
                    '<TD colspan="5" style="text-align: center; text-valign: top; font-size: 10px;">Ф.И.О.</TD>' skip
                    '<TD style=""></TD>'
                    '</TR>'skip                            
                            
                    '<TR>' skip
                    '<TD colspan="12" style="">Представитель незаинтересованной организации <*></TD>' skip
                    '<TD colspan="9" style="border-bottom: 1px solid black; text-align: center;"></TD>' skip
                    '</TR>'skip
                            
                    '<TR><TD colspan="21" style="height: 14px;"></TD></TR>' skip
                            
                    '<TR>' skip
                    '<TD colspan="8" style="border-top: 1px solid black; text-align: center;"></TD>' skip
                    '<TD colspan="12" style=""></TD>' skip
                    '</TR>'skip
                            
                    '<TR><TD colspan="21" style="height: 14px;"><*> Подпись ставится, если проба отбирается для арбитражного анализа</TD></TR>' skip

                    .

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
            
            end.    /*      if is-petrolium        */
        end.    /*        for each buf_doc-line     */

    end.

end.

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
    define variable v-name as character no-undo . 
    define buffer buf_person for ub.person .    
    find first buf_person no-lock where buf_person.psn-code = p-obj-code no-error .
    if AVAILABLE buf_person then 
    do:
        run rep/get-psn.p(input buf_person.psn-code, output v-name ).
        p-obj-name = v-name + '  ' + buf_person.name1 + ' ':U + buf_person.name2.
        
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
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.