/*

$Revision: 096e36ceea80, 2676, rls $
$Author: EShklyar $
$Date: Вт ноя 17 10:53:21 2020 +0300 $
$Workfile: r-orioxl-sug.i $
$Archive: rep/r-orioxl-sug.i $

Шапка и подвал для отчета инвентаризации СУГ

Автор: Булгаков Андрей Николаевич
Дата создания: 05/23/06
Author: Andrew Bulgakoff
Creation date: 05/23/06

*/

&scoped-define vssseq {&sequence}

define variable vss-include-info{&vssseq} as character no-undo format "x(65)":U
  initial "@(#)$Workfile: r-orioxl-sug.i $ $Revision: 096e36ceea80, 2676, rls $":U .

{ gbl/std-func.i {&f-l} }

procedure shapka-inv :
  put stream OutStr-html unformatted
    '<body>' skip
    /*Первая таблица*/
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '</tr>' skip
    .  
  put stream OutStr-html unformatted
    '<TR><TD colspan="86"></TD></TR>' skip

    '<TR>' skip
    '<TD colspan="25" style="height: 14px; text-align: left;">Наименование организации</TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="25" style="height: 14px; border-bottom: 1px solid black; text-align: left;">' + v-host-name + '</TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="25" style="height: 14px; text-align: left;">' + bf_object.obj-name + '</TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="25" style="height: 14px"></TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip
        
    '<TR>' skip
    '<TD colspan="86" style="text-align: center;">ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ СУГ</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="86" style="text-align: center;">' + "№ " + string(bf_trn-doc.doc-code) + " от " + string (day( t_inv-date )) + " " + string(MonthNameRusCase( month( t_inv-date ), 2 )) + " " + string(year( t_inv-date )) + "г. " + '</TD>' skip
    '</TR>'skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    
    '<TR>' skip
    '<TD colspan="86" style="text-align: center;">Расписка</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">К началу проведения инвентаризации все приходные и расходные документы и товарно-</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">материальные ценности включены в отчеты (реестры), сданы в бухгалтерию и все ценности,</TD>' skip
    '</TR>'skip
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">поступившие на мою (нашу) ответственность, оприходованы, а выбывшие списаны в расход.</TD>' skip
    '</TR>'skip
    
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="86" style="">Материально ответственные (ое) лица (лицо):</TD>' skip
    '</TR>'skip

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip                                                         

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip                                                        

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip          

    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    .
    if v-prikaz-date <> "" then do:
       put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" colspan="86" style="">На основании распоряжения от ' + string (day( date(v-prikaz-date) )) + " " + string(MonthNameRusCase( month( date(v-prikaz-date) ), 2 )) + " " + string(year( date(v-prikaz-date) )) + "г. " + if v-prikaz-num = "" then "№ __________" + '</TD>' else '№ ' + string(v-prikaz-num) + '</TD>' skip
      '</TR>'skip
      .
    end.
    else do:
     put stream OutStr-html unformatted  
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">На основании распоряжения от "_____" _______________ 20____ г.' + if v-prikaz-num = "" then "№ __________" + '</TD>' else '№ ' + string(v-prikaz-num) + '</TD>' skip
    '</TR>'skip
    .
    end.
     put stream OutStr-html unformatted                                                        
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">произведено снятие фактических остатков СУГ</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">по состоянию на "_____" _______________ 20____ г.</TD>' skip
    '</TR>'skip
    
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    .
    if v-doc-date <> "" then do:
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">Инвентаризация начата</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">' + string (day( date(v-doc-date) )) + " " + string(MonthNameRusCase( month( date(v-doc-date) ), 2 )) + " " + string(year( date(v-doc-date) )) + "г. " 'в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .
    end.
    else do:
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">Инвентаризация начата</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">' + string (day( date(bf_trn-doc.doc-date) )) + " " + string(MonthNameRusCase( month( date(bf_trn-doc.doc-date) ), 2 )) + " " + string(year( date(bf_trn-doc.doc-date) )) + "г. " 'в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .

    end.
    if bf_trn-doc.fact-date <> ? then do:
    put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">окончена</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">' + string (day( bf_trn-doc.fact-date )) + " " + string(MonthNameRusCase( month( bf_trn-doc.fact-date ), 2 )) + " " + string(year( bf_trn-doc.fact-date )) + "г. " 'в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .
    end.
    else do:
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">окончена</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">"_____" ______________ 20 _____ г. в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .
    end.
  put stream OutStr-html unformatted            
    '</thead>' skip
    .        
end procedure. /* shapka-inv */

procedure foot-inv :
  put stream OutStr-html unformatted
    '<tfoot>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '</tr>' skip
    .  
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="17" style="">Общие замечания</TD>' skip
    '<TD text_wrap="true" colspan="69" style="border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
                
    '<TR>' skip
    .
    if j_LineCount = 0 then do:
    put stream OutStr-html unformatted
    '<TD text_wrap="true" colspan="86" style="">Все ценности, поименованные в описи c №  ' + "0" + ' по № ' + string(j_LineCount) + ', комиссией проверены в натуре</TD>' skip
    .
    end.
    else do:
    put stream OutStr-html unformatted
    '<TD text_wrap="true" colspan="86" style="">Все ценности, поименованные в описи c №  ' + "1" + ' по № ' + string(j_LineCount) + ', комиссией проверены в натуре</TD>' skip
    .  
    end.  
     put stream OutStr-html unformatted    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style=""> в моем (нашем) присутствии и внесены в опись, в связи с чем претензий к инвентаризационной</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style=""> комиссии не имею (не имеем). Ценности, перечисленные в описи, находятся на моем (нашем)</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">ответственном хранении</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip    
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Материально ответственные(ое) лица(лицо):</TD>' skip
    '</TR>'skip

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip                                                        

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip                                                        

    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="20" style="">Председатель комиссии:</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-agent + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-agent + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip                                                        

    '<TR>' skip
    '<TD text_wrap="true" colspan="20" style="">Состав комиссии:</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-player1 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-player1 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip           
    
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="20" style=""></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-player2 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-player2 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip           

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="20" style=""></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-player3 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-player3 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Снятие остатков СУГ, указанных в описи, произведено при нашем личном участии.</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Все взятые документы и деньги во время проверки возвращены нам полностью в надлежащем</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">порядке и претензий к комиссии (проверяющему) не имеем. Настоящую опись читали и</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">один экземпляр описи получили (объяснение предоставляется вместе с описью).</TD>' skip
    '</TR>'skip                
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Материально ответственные(ое) лица(лицо):</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip                                                        

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip                                                        

    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip   
    '<tr><td text_wrap="true" colspan="86">* ** Указанное значение выводится для справки</td></tr>' skip  
    .  
                
  put stream OutStr-html unformatted            
    '</tfoot>' skip
    .        

end procedure. /* foot-inv */
/* $Workfile: r-orioxl-sug.i $   E n d */