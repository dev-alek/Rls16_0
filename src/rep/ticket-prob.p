/*

$Revision: 8ee12a69ba68, 1075, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:37:43 2017 +0300 $
$Workfile: ticket-prob.p $
$Archive: rep/ticket-prob.p $

Этикетка проб

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
define variable vss-workfile    as character no-undo init "$Workfile: ticket-prob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/ticket-prob.p $":U .
define variable vss-description as character no-undo init "Этикетка проб".
{ cmp/vssrevis.i }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

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
define VARIABLE v-tank-vol          as decimal   no-undo .
DEFINE VARIABLE v-tank-density      as DECIMAL   no-undo .
define VARIABLE v-tank-weight       as decimal   no-undo .
define variable v-tank-temp         as decimal   no-undo .
define variable v-date-prob         as date      no-undo .
define variable v-hour-prob         as integer   no-undo .
define variable v-min-prob          as integer   no-undo .
define variable v-attr-value        as character    no-undo .
define variable v-obj-type          as character    no-undo .
define variable v-obj-code          as integer      no-undo .

define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .

define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_goods         for ub.goods.
define buffer buf_rvs-line      for ub.rvs-line.
define buffer buf_rvs-doc       for ub.rvs-doc.
define buffer buf_clients       for ub.clients.
define buffer buf_firm          for ub.firm.
    
do
    on error undo, return error return-value
    :

    find first buf_trn-doc no-lock
        where recid( buf_trn-doc ) = rec_id.
    /*Общие данные*/
    
    /*Название объекта*/
    run clients-write(INPUT buf_trn-doc.obj-code,INPUT buf_trn-doc.obj-type,OUTPUT v-obj-name) no-error .    
    /*Название поставщика*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-ptbobj},OUTPUT v-attr-value) no-error .
    if v-attr-value = "" then do:
        run clients-write(INPUT buf_trn-doc.cli-code,INPUT buf_trn-doc.cli-type,OUTPUT v-producer) no-error .
    end.    
    else do:
        assign
        v-obj-code = integer (entry (2, v-attr-value, ";"))
        v-obj-type = entry (1, v-attr-value, ";")
        .
        run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-producer) no-error .
    end.    
    run clients-write(INPUT buf_trn-doc.cli-code,INPUT buf_trn-doc.cli-type,OUTPUT v-producer) no-error .
    /*Водитель-экспедитор*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-fio-driver},OUTPUT v-driver) no-error .
    /*Гос номер авто*/                                        
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-car-num},OUTPUT v-num-car) no-error .
    

    /*Оператор*/
    run clients-write(INPUT buf_trn-doc.wrkr, INPUT {&prs}, OUTPUT v-fio) no-error .
    
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

                do iNum = 1 to v-InfoSectionsTotal:SectionNum:
                    if v-InfoSectionsTotal:GetInfoSectionProp(iNum):Tests <> "" and v-InfoSectionsTotal:GetInfoSectionProp(iNum):Tests <> ? then 
                    do:
                        assign
                            v-num-prob     = v-InfoSectionsTotal:GetInfoSectionProp(iNum):Tests
                            v-norm-doc     = v-InfoSectionsTotal:GetInfoSectionProp(iNum):NormDoc
                            v-tank-vol     = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankVol
                            v-tank-density = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankDensity .
                        if v-tank-density <> 0 then v-tank-weight  = v-tank-vol * v-tank-density .
                        assign
                            v-tank-temp = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankTemp
                            v-date-prob = v-InfoSectionsTotal:GetInfoSectionProp(iNum):DateProb
                            v-hour-prob = v-InfoSectionsTotal:GetInfoSectionProp(iNum):HourProb
                            v-min-prob  = v-InfoSectionsTotal:GetInfoSectionProp(iNum):MinProb
                            .
                    
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
                                '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
                                '<thead>' skip
                                .
                            put stream OutStr-html unformatted
                                '<tr>' skip
                                '<td style="width: 93px;"></td>' skip
                                '<td style="width: 108px;"></td>' skip
                                '<td style="width: 47px;"></td>' skip
                                '<td style="width: 48px;"></td>' skip
                                '<td style="width: 74px;"></td>' skip
                                '<td style="width: 124px;"></td>' skip
                                '</tr>' skip
                                .   
                        do jj = 1 to 2 :        
                        put stream OutStr-html unformatted
                            '<TR><TD colspan="6"></TD></TR>' skip
                            '<TR>' skip
                            '<TD style="border-top: 2px solid black; border-left: 2px solid black;"></TD>' skip
                            '<TD style="border-top: 2px solid black;"></TD>' skip
                            '<TD style="border-top: 2px solid black;"></TD>' skip
                            '<TD style="border-top: 2px solid black;"></TD>' skip
                            '<TD style="border-top: 2px solid black;"></TD>' skip
                            '<TD style="border-top: 2px solid black; border-right: 2px solid black;"></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black; text-align: right; font-weight: bold;">АЗС №</TD>' skip
                            '<TD style="">' + v-obj-name + '</TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style="text-align: right; font-weight: bold;">проба №</TD>' skip
                            '<TD style="border-right: 2px solid black;">' + v-num-prob + '</TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD colspan="2" style="border-left: 2px solid black; font-weight: bold;">Вид нефтепродукта</TD>' skip
                            '<TD colspan="4" style="border-right: 2px solid black; text-align: center;">' + v-gds-name + '</TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black; font-weight: bold;">ГОСТ (ТУ)</TD>' skip
                            '<TD colspan="4" style="text-align: center;">' + v-norm-doc + '</TD>' skip
                            '<TD rowspan="3" style="border-right: 2px solid black; text-align: center;">
                        <img src="logo-rn.jpg"/></TD>' skip
                            '</TR>'skip                     
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black; font-weight: bold;">№ ТТН</TD>' skip
                            '<TD colspan="2" style="">' + v-doc-code-attr + '</TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black;">Объем</TD>' skip
                            '<TD num="0.0" val="' + fnc-convert-dot-to-colon(v-tank-vol,"->>>>>>>>>>>9.9",1) + '" style="font-weight: bold;">' + fnc-convert-dot-to-colon(v-tank-vol,"->>>>>>>>>>>9.9",1) + '</TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style="text-align: right; font-weight: bold;"></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black;">Плотность</TD>' skip
                            '<TD num="0.0000" val="' + fnc-convert-dot-to-colon(v-tank-density,"->>>>>>>>>>>9.9999",4) + '" style="font-weight: bold;">' + fnc-convert-dot-to-colon(v-tank-density,"->>>>>>>>>>>9.9999",4) + '</TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style="text-align: right; font-weight: bold;"></TD>' skip
                            '<TD style="border-right: 2px solid black; text-align: right;"></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black;">Температура</TD>' skip
                            '<TD num="0.0" val="' + fnc-convert-dot-to-colon(v-tank-temp,"->>>>>>>>>>>9.9",1) + '" style="font-weight: bold;">' + fnc-convert-dot-to-colon(v-tank-temp,"->>>>>>>>>>>9.9",1) + '</TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style="text-align: right; font-weight: bold;"></TD>' skip
                            '<TD style="border-right: 2px solid black; text-align: right;"></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black;">Масса</TD>' skip
                            '<TD num="0.000" val="' + fnc-convert-dot-to-colon(v-tank-weight,"->>>>>>>>>>>9.999",3) + '" style="font-weight: bold;">' + fnc-convert-dot-to-colon(v-tank-weight,"->>>>>>>>>>>9.999",3) + '</TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style="text-align: right; font-weight: bold;"></TD>' skip
                            '<TD style="border-right: 2px solid black; text-align: right;"></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black; font-weight: bold;">Оператор</TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD colspan="3" style="font-weight: bold;">' + v-fio + '</TD>' skip
                            '<TD style="border-right: 2px solid black; text-align: right;"></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black; text-align: right; font-weight: bold;"></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD style=""></TD>' skip
                            '<TD colspan="2" style="border-right: 2px solid black; border-top: 2px solid black; text-align: center;">подпись</TD>' skip
                            '</TR>'skip                                                                                                                                                           
                            '<TR>' skip
                            '<TD colspan="2" style="border-left: 2px solid black; font-weight: bold;">Водитель-экспедитор</TD>' skip
                            '<TD colspan="3" style="font-weight: bold;">' + v-driver + '</TD>' skip
                            '<TD style="border-right: 2px solid black; text-align: right;"></TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD colspan="2" style="border-left: 2px solid black; font-weight: bold;">Гос. номер авт.</TD>' skip
                            '<TD colspan="2" style="text-align: center; font-weight: bold;">' + v-num-car + '</TD>' skip
                            '<TD style="border-top: 2px solid black;"></TD>' skip
                            '<TD style="border-right: 2px solid black; border-top: 2px solid black;">подпись</TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD colspan="3" style="border-left: 2px solid black; font-weight: bold;">Дата и время отбора пробы</TD>' skip
                            '<TD colspan="2" style="text-align: right; font-weight: bold;">' + if string(v-date-prob) <> ? then string(v-date-prob,"99/99/9999") + '</td>' else "01/01/1900" + '</TD>' skip
                            '<TD style="border-right: 2px solid black; text-align: right; font-weight: bold;">' + string(v-hour-prob,"99") + ":" + string(v-min-prob,"99") + '</TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-left: 2px solid black; font-weight: bold;">Поставщик</TD>' skip
                            '<TD colspan="5" style="border-right: 2px solid black; text-align: center; font-weight: bold;">' + v-producer + '</TD>' skip
                            '</TR>'skip
                            '<TR>' skip
                            '<TD style="border-bottom: 2px solid black; border-left: 2px solid black;"></TD>' skip
                            '<TD style="border-bottom: 2px solid black;"></TD>' skip
                            '<TD style="border-bottom: 2px solid black;"></TD>' skip
                            '<TD style="border-bottom: 2px solid black;"></TD>' skip
                            '<TD style="border-bottom: 2px solid black;"></TD>' skip
                            '<TD style="border-bottom: 2px solid black; border-right: 2px solid black;"></TD>' skip
                            '</TR>'skip   
                            .

                            end.
                            put stream OutStr-html unformatted
                                '</thead>' skip
                                '</table>' skip
                                '</body>' skip
                                '</html>' skip
                                .
                                                                                                                
                            run prn-lib-reportviewer-report-name in this-procedure (
                                input THIS-PROCEDURE
                                ,input v-file-name-rep-htm
                                ).

                    end.

                end.
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