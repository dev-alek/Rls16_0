block-level on error undo, throw.
/*

$Revision: 992a74a9441b, 3581, rls $
$Author: VSpiridonov $
$Date: 2023/12/14 13:36:13 $
$Workfile: akt-np-make.p $
$Archive: rep/akt-np-make.p $

Печатные формы. Акт учета НП при проведении Ремонтных работ

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/15/05
Author: Victor Guntner
Creation date: 09/15/05

Input:
    rec_id          as recid        - recid складского документа (trn-doc)

Output:

*/
do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: 992a74a9441b, 3581, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: akt-np-make.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/akt-np-make.p $":U .
define variable vss-description as character no-undo init "Печатные формы. Акт учета НП при проведении Ремонтных работ".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i          }
{ str/trdcalib.i        }
{ str/in-vatp.i def     }
{ str/out-vatp.i def    }
{ rep/r-cliprp.i def    }
{ rep/fmtcli.i          }
{ gbl/clntattr.i        }
{ rep/torgconf.i        }
{ str/getctxtp.i def    }
{ gbl/prn-lib.i }

define buffer t-doc        for trn-doc.
define buffer b-trn-doc    for trn-doc.
define buffer OurObject    for clients.

define shared variable PrintScale      as logical                   no-undo.
define shared variable CostPrice       as logical                   no-undo.
define shared variable no-vat          as logical                   no-undo.

define variable v-base-code     as integer                          no-undo.

define variable rootnode_code   as integer                          no-undo.

define variable Node_Code       like gds-prt.upper-code             no-undo.

define variable tqnty           like ot-line.fact-qnty              no-undo.


define variable tdoc-code           like trn-doc.doc-code  no-undo.
define variable v-doc-date-string   as character           no-undo.
define variable v-host-code         as integer             no-undo.
DEFINE VARIABLE v-pl-code       like pl-gds.pl-code        no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

/*переменные для отчета HTML*/
define stream Out-Stream.
define stream OutStr-html.
define variable v-report-name-html as character no-undo .
define variable v-report-name-html-list as character no-undo .
define variable v-report-name-html-result as character no-undo .
define variable v-report-result         as logical   no-undo .

{ str/getctxtp.i get p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).

  v-report-name-html = session:temp-directory + {&DF_Name} + string(g#report-num) + ".html". /*формирование имя файла*/
  
/*run get-quest-print in p-mainmenu-handle (*/
/*    output g#quest-print                  */
/*).                                        */
/*временная таблица для передачи параметров*/
{ gbl/paramls.i         }

find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
{ gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
}
if v-torgconf-outnum = yes
then do:
    assign
        tdoc-code = fill( " ", 10 )
    .
end.
else do:
    assign
        tdoc-code = t-doc.doc-code
    .
end.
if v-torgconf-outdate = yes
then do:
    assign
        v-doc-date-string = fill( " ", 10 )
    .
end.
else do:
    assign
        v-doc-date-string = ( if t-doc.status_ <> {&fact}
                            then string( t-doc.doc-date,  "99/99/9999" )
                            else string( t-doc.fact-date, "99/99/9999" )
                            )
    .
end.

find first OurObject no-lock
     where OurObject.obj-type = t-doc.obj-type
       and OurObject.obj-code = t-doc.obj-code
no-error.

find first clients no-lock
     where clients.obj-type = {&cmp}
       and clients.obj-code = t-doc.host-code
.
for  each doc-line no-lock
    where doc-line.doc-code = t-doc.doc-code
break by doc-line.artic
:
    find first goods no-lock
         where goods.prod-type = doc-line.prod-type
           and goods.prod-code = doc-line.prod-code
           and goods.artic = doc-line.artic
    .
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    assign
        rootnode_code = gds-prt.node-code
    .

            find first bar-code no-lock
                 where bar-code.gds-code = goods.gds-code
                   and bar-code.unit-cli = goods.unit-base
                   and bar-code.node-code = rootnode_code
                   and bar-code.part-code = ""
                   and bar-code.in-code = ""
            .
            find first gds-dtl no-lock
                 where gds-dtl.doc-code = doc-line.doc-code
                   and gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.prt-code = rootnode_code
            .

            assign
                tqnty = gds-dtl.fact-qnty
            .
        find first pl-gds where pl-gds.gds-code = goods.gds-code
                            and pl-gds.obj-code = OurObject.obj-code
                            and pl-gds.obj-type = OurObject.obj-type no-error.
           if AVAILABLE pl-gds then do:
               v-pl-code = pl-gds.pl-code .
           end.                                 

    accumulate
        tqnty (total)
    .

 /*Печать шапки*/
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
        substitute(
          '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       
                        
                       
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   td, th ~{
                       border: 0px solid black;
                       border-collapse: collapse;
                       text_wrap: true;              
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="portrait" name="&1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                    <thead>  
                      <tr class="set_columns">
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:80px"></td>
                        <td style="width:200px"></td>
                        <td style="width:10px"></td>
                      </tr>
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="4" style="text-align: center; height: 30px;">Утверждаю</td>
                    </tr>
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="4" style="border-bottom: 1px solid black; height: 30px;"></td>
                    </tr>
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="4" style="text-align: center;">(должность руководителя)</td>
                    </tr>                    
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="4" style="border-bottom: 1px solid black; text-align: center; height: 30px;"></td>
                    </tr>
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="4" style="text-align: center;">(фамилия, инициалы руководителя)</td>
                    </tr>
                    <tr>
                      <td colspan="5"></td>
                      <td colspan="4" style="height: 30px;">" ___ "  __________________  20__  г.</td>
                    </tr>
                    <tr>
                      <td colspan="9" style="height: 150px;"></td>
                    </tr> 
                    <tr>
                      <td colspan="9" style="text-align: center; height: 30px;">АКТ</td>
                    </tr>
                    <tr>
                      <td colspan="9" style="text-align: center; height: 30px;">учета нефтепродуктов при выполнении</td>
                    </tr>   
                    <tr>
                      <td colspan="9" style="text-align: center; height: 30px;">ремонтных работ на ТРК (МРК)</td>
                    </tr>   
                    <tr style="height: 30px;">
                      <td colspan="4">Основание выполнения работ</td>
                      <td colspan="5" style="border-bottom: 1px solid black;"></td>
                    </tr>  
                    <tr style="height: 30px;">
                      <td colspan="4">Исполнители ремонтных работ</td>
                      <td colspan="5" style="border-bottom: 1px solid black;"></td>
                    </tr>  
                    <tr>
                      <td colspan="4" style="text-align: right;"></td>
                      <td colspan="5" style="text-align: center;">(должность, фамилия и инициалы)</td>
                    </tr>  
                    <tr style="height: 30px;">
                      <td colspan="9" style="border-bottom: 1px solid black;"></td>
                    </tr>  
                    <tr>
                      <td colspan="9" style="text-align: center;">(должность, фамилия и инициалы)</td>
                    </tr>  
                    <tr style="height: 30px;">
                      <td colspan="3">Оператор АЗС</td>
                      <td colspan="6" style="border-bottom: 1px solid black;"></td>
                    </tr> 
                    <tr style="height: 30px;">
                      <td colspan="4">&2</td>
                      <td>на АЗС</td>
                      <td colspan="4" style="text-align: center; border-bottom: 1px solid black;">&3</td>
                    </tr>  
                    <tr>
                      <td colspan="4"></td>
                      <td></td>
                      <td colspan="4" style="text-align: center;">(№ или наименование АЗС)</td>
                    </tr>
                    <tr style="height: 30px;">
                      <td colspan="3">принадлежащей</td>
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&4</td>
                      <td></td>
                    </tr>
                    <tr style="height: 30px;">
                      <td colspan="2">Продукт</td>
                      <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&5</td>
                      <td colspan="5" style="text-align: center;">, отпущенный через ТРК № __________, пост</td>
                    </tr> 
                    <tr style="height: 30px;">
                      <td colspan="4">№ _________________________ в объеме</td>
                      <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&6</td>
                      <td colspan="3" style="text-align: right;"> литров в резервуар </td>
                    </tr> 
                    <tr style="height: 30px;">
                      <td>№</td>
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&7</td>
                      <td colspan="5"></td>
                    </tr> 
                    <tr style="height: 30px;">
                      <td colspan="6">Показания суммарного счетчика до прокачки</td>
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: right;">,</td>
                     
                    </tr> 
                    <tr style="height: 30px;">
                      <td colspan="4"></td>  
                      <td colspan="2">после прокачки</td>
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: right;">.</td>
                      
                    </tr> 
                    <tr style="height: 60px;">
                      <td colspan="2">Подписи</td>  
                      <td colspan="4" style="border-bottom: 1px solid black;"></td>
                      <td colspan="3"></td>
                    </tr> 
                    <tr style="height: 30px;">
                      <td colspan="2"></td>  
                      <td colspan="4" style="border-bottom: 1px solid black;"></td>
                      <td colspan="3"></td>
                    </tr> 
                    <tr style="height: 30px;">
                      <td colspan="2"></td>  
                      <td colspan="4" style="border-bottom: 1px solid black;"></td>
                      <td colspan="3"></td>
                    </tr> 
                    </thead>'
      ,
        string(goods.gds-code),
        v-doc-date-string,
        string(OurObject.obj-name),
        string(t-okpo),
        string(goods.gds-name),
        tqnty,
        v-pl-code
      ).

      put stream OutStr-html unformatted                                                                     
        substitute (
        '
        </body>
        </html>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
       ).                                                                                                               
output stream OutStr-html close.
        


/*шапка таблицы HTML*/
         
end.        /*for  each doc-line ...*/

        run prn-lib-reportviewer in this-procedure (
            input p-mainmenu-handle
            ,input v-report-name-html
            ,input "" 
            ) no-error.
        if error-status:error then
        do:
            message return-value view-as alert-box.
            return .
        end.
        


end.