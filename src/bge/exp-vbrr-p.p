block-level on error undo, throw.


/*

$Revision: 2b5d171fb0ff, 3604, rls $
$Author: ARostovtsev $ Shalanin Sergey   $  
$Date: 2023/12/28 12:56:37 $ 10/10/2015 $
$Workfile: exp-VBRR-p.p $ exp-VBRR-p.p $
$Archive: bge/exp-VBRR-p.p $ bge/exp-VBRR-p.p $

Процедура выгрузки.VBBR

Автор: Шаланини Сергей
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10



*/


define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $ SShalanin":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-VBRR-p.p $ exp-VBRR-p.p ":U .
define variable vss-archive     as character no-undo init "$Archive: bge/exp-VBRR-p.p $ bge/exp-VBRR-p.p ":U .
define variable vss-description as character no-undo init "Процедура выгрузки.VBBR".

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Includes  ************************** */

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/lib-trn.i  }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ ref/gds-attr.i }
{ gbl/ftp-df.i }



DEFINE INPUT PARAMETER p-log-handle AS HANDLE NO-UNDO. /* handle по которому находится процедура записи лога */
DEFINE INPUT PARAMETER p-directory AS CHARACTER NO-UNDO. /* Папка для выгрузки , либо ftp адресс*/
define input parameter p-place as integer no-undo.
define input parameter p-login as char no-undo.
define input parameter p-password as char no-undo.
define input parameter p-code_TNP as char no-undo.
define input parameter p-code_pool as char no-undo.
define input parameter p-code_system as integer no-undo.
define input parameter p-long-code as integer no-undo.


define variable v-ext-class-grp as character no-undo.
define variable v-upper-code as integer no-undo.
define variable v-localcode   as char      no-undo.
define variable v-is-petrol   as logical   no-undo.
define variable v-is-pieces   as logical   no-undo.
define variable xml-date-file as character no-undo.
define variable xml-time-file as character no-undo.
DEFINE VARIABLE file_name     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-date-file   AS CHARACTER NO-UNDO.
DEFINE VARIABLE log-file-name AS CHARACTER NO-UNDO. 
define variable v-vat-pc      as decimal   no-undo.
define variable par-type as character no-undo.
define variable  ptrl as character no-undo.
define variable v-number as character no-undo.

define variable  v-units-okei as integer no-undo.
define buffer buf_ext-classif for ext-classif.
define buffer buf_goods       for goods.
define buffer buf_goods-attr  for goods-attr.
define buffer buf_units for units.
define buffer buf_gds-grp for gds-grp.
define buffer buf_code for ub.code.
xml-date-file = STRING(YEAR(TODAY), "9999") + "-" + STRING(MONTH(TODAY), "99") + "-" + STRING(DAY(TODAY), "99").
xml-time-file = substring(string(time,"HH:MM:SS"),1,2) + ":" + substring(string(time,"HH:MM:SS"),4,2) + ":" + substring(string(time,"HH:MM:SS"),7,2).
v-number = substring(string(time,"HH:MM"),1,2) + substring(string(time,"HH:MM"),4,2).
v-date-file  = STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") +    string(integer(v-number), fill("9", 5)).
          { gbl/conf-rd.i
 "'spl-ptrl'"
 "''":U
 "''":U
 "''":U
 "''":U
 "''":U
 "''":U
 NO
 ptrl
 par-type
 NO-ERROR
 }



if p-place = 1 then
do:
    log-file-name = p-directory + "Goods-VBBR.txt":U.
    file_name = p-directory + ' Goods':U + string(integer(ptrl) , fill("9", 5 ))  + v-date-file  + '.xml'.
     
end.

if p-place = 2 then
do:

    file_name = session:temp-directory + 'Goods':U +  string(integer(ptrl) , fill("9", 5) )  +  v-date-file  + '.xml'.
    assign
        log-file-name = "Goods-VBBR.log"
        .
 &scop display-message    run write-log-and-file in p-log-handle (  ~
         input 1                                                      ~
         , input log-file-name                                          ~
         , input 1                                                      ~
         , input ~{&my-message~})
end.

define variable hSAXWriter as handle no-undo.    
  
create sax-writer hSAXWriter no-error.
hSAXWriter:set-output-destination("file":U, file_name) no-error.
hSAXWriter:formatted = true.
hSAXWriter:encoding = "windows-1251":U.
hSAXWriter:start-document() no-error.
    
hSAXWriter:START-ELEMENT ("GoodsLocalFile") no-error.
      
hSAXWriter:START-ELEMENT ("FileHeader") no-error.
hSAXWriter:WRITE-DATA-ELEMENT("FileLabel" , "FG"  ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("FormatVersion" , "1.0"  ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("Sender" , ptrl ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("CreationDate" , xml-date-file ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("CreationTime" , xml-time-file ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("Number" ,  string(integer(v-number), fill("9", 5)) ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("Institution" , string(integer(ptrl) , fill("9", 5) ) ) no-error.
hSAXWriter:end-ELEMENT ("FileHeader") no-error.
       
hSAXWriter:START-ELEMENT ("GoodsLocalSets") no-error.
         
hSAXWriter:START-ELEMENT ("GoodsLocalSet") no-error.
         
hSAXWriter:WRITE-DATA-ELEMENT("Code" , p-code_pool) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("Name" , p-code_pool ) no-error.
         
hSAXWriter:START-ELEMENT ("GoodsLocalItems") no-error.
   
    
for each buf_goods where buf_goods.stts = 0  no-lock :
    
     find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base  no-error.
           v-units-okei = buf_units.okei.
     
    
    if buf_goods.gds-type = {&gds-office} and  can-find (first buf_goods-attr where buf_goods-attr.gds-code = buf_goods.gds-code and buf_goods-attr.attr-code = {&attr-office-type} )  then next. 
        
            
    if not buf_goods.gds-type = {&gds-office} then 
    do:
         
    { str/is-petrl.i
                    buf_goods.artic
                    buf_goods.prod-type
                    buf_goods.prod-code
                    v-is-petrol
                    v-is-pieces
      }
    end.


    if buf_goods.gds-type = {&gds-office} or  v-is-petrol then 
    do:
    
        find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_goods}
            and buf_ext-classif.classif-name = {&extclass_goods_esys}
            and buf_ext-classif.key#_two = p-code_system
            and buf_ext-classif.key#_three = 0 
            and buf_ext-classif.key#_one = buf_goods.gds-code no-error.
                
      
        /*                &scop display-message    run write-log-and-file in p-log-handle (  ~*/
        /*         input 1                                                      ~             */
        /*         , input log-file-name                                          ~           */
        /*         , input 1                                                      ~           */
        /*         , input ~{&my-message~})                                                   */
        if not available buf_ext-classif then 
        do:

      run  grp-line (input buf_goods.grp-code, output v-ext-class-grp ) .
         
           if  v-ext-class-grp <> ""  then   do:
         v-localcode =  v-ext-class-grp. 
         
          { gbl/pgtxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-vat-pc no-error }

        hSAXWriter:START-ELEMENT ("GoodsLocalItem") no-error.

        hSAXWriter:WRITE-DATA-ELEMENT("ExtCode" , string(buf_goods.gds-code, fill("9", p-long-code)) ) no-error.

        hSAXWriter:WRITE-DATA-ELEMENT("GoodsItemCode" , string(v-localcode) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("Name" , buf_goods.gds-name) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("LatinName" , buf_goods.engl-name) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("VAT" , string(v-vat-pc)) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("AddData", "UNIT_TYPE=" + string(v-units-okei) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("UnitType" , string(v-units-okei) ) no-error.

        hSAXWriter:WRITE-DATA-ELEMENT("IsActive" , "Yes") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("EffectiveDate" , "2010-01-01") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("ExpirationDate" , "2100-01-01") no-error.
        
        hSAXWriter:end-ELEMENT ("GoodsLocalItem") no-error.
         end.
          else do:
              
                 &scop my-message SUBSTITUTE("Товар: &1 &2.", buf_goods.gds-name, buf_goods.gds-code)
                    {&display-message}.

                 &scop my-message substitute("Ошибка: нет соответствующего кода внешней системы ")
                    {&display-message}.
                 
         
         end.

         
         
  end.
        /*   &scop my-message SUBSTITUTE("Товар: &1 &2.", buf_goods.gds-name, buf_goods.gds-code)   */
        /*            {&display-message}.                                                           */
        /*                                                                                          */
        /*         &scop my-message substitute("Ошибка: нет соответствующего кода внешней системы ")*/
        /*            {&display-message}.                                                           */
        /*            next.                                                                         */
  
        else 
        do:
            v-localcode = buf_ext-classif.charkey_one.
    
/*             message v-localcode view-as alert-box.*/
    
    
        { gbl/pgtxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-vat-pc no-error }

        hSAXWriter:START-ELEMENT ("GoodsLocalItem") no-error.

        hSAXWriter:WRITE-DATA-ELEMENT("ExtCode" , string(buf_goods.gds-code, fill("9", p-long-code)) ) no-error.

        hSAXWriter:WRITE-DATA-ELEMENT("GoodsItemCode" , string(v-localcode) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("Name" , buf_goods.gds-name) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("LatinName" , buf_goods.engl-name) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("VAT" , string(v-vat-pc)) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("AddData", "UNIT_TYPE=" + string(v-units-okei) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("UnitType" , string(v-units-okei) ) no-error.

        hSAXWriter:WRITE-DATA-ELEMENT("IsActive" , "Yes") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("EffectiveDate" , "2010-01-01") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("ExpirationDate" , "2100-01-01") no-error.
        
        hSAXWriter:end-ELEMENT ("GoodsLocalItem") no-error.
            end.
           
    end. 
    else 
    do: 
        
        
        find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_goods}
            and buf_ext-classif.classif-name = {&extclass_goods_esys}
            and buf_ext-classif.key#_two = p-code_system
            and buf_ext-classif.key#_three = 0 
            and buf_ext-classif.key#_one = buf_goods.gds-code no-error.
            
            
            
        if not available buf_ext-classif then 
        do:

            run  grp-line (input buf_goods.grp-code, output v-ext-class-grp ) .
              
              if  v-ext-class-grp <> ""  then   do:
         v-localcode =  v-ext-class-grp. 
         end.
          else do:
          v-localcode = p-code_TNP.
         end.

         
        end.
        /*   &scop my-message SUBSTITUTE("Товар: &1 &2.", buf_goods.gds-name, buf_goods.gds-code)   */
        /*            {&display-message}.                                                           */
        /*                                                                                          */
        /*         &scop my-message substitute("Ошибка: нет соответствующего кода внешней системы ")*/
        /*            {&display-message}.                                                           */
        /*            next.                                                                         */
  
        else 
        do:
            v-localcode = buf_ext-classif.charkey_one.
        end.
/*                   message v-localcode view-as alert-box.*/
      
    
           
    { gbl/pgtxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-vat-pc no-error }
        hSAXWriter:START-ELEMENT ("GoodsLocalItem") no-error.

        hSAXWriter:WRITE-DATA-ELEMENT("ExtCode" , string(buf_goods.gds-code, fill("9", p-long-code)) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("GoodsItemCode" , string(v-localcode)) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("Name" , buf_goods.gds-name) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("LatinName" , buf_goods.engl-name) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("VAT" , string(v-vat-pc)) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("AddData", "UNIT_TYPE=" + string(v-units-okei) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("UnitType" , string(v-units-okei) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("IsActive" , "Yes") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("EffectiveDate" , "2010-01-01") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("ExpirationDate" , "2100-01-01") no-error.
 
        
        hSAXWriter:end-ELEMENT ("GoodsLocalItem") no-error.
    end.  
end.

/* Соберем Сезоны ДТ */
for each buf_code no-lock where
         buf_code.parent  = "DTSeasons":
  find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_goods}
      and buf_ext-classif.classif-name = {&extclass_goods_esys}
      and buf_ext-classif.key#_two = p-code_system
      and buf_ext-classif.key#_three = 0 
      and buf_ext-classif.key#_one = integer(buf_code.code) no-error.
  if available buf_ext-classif then
  do:
    find first buf_units no-lock where 
               buf_units.unit-name = buf_code.misc3 no-error.
    v-units-okei = if available buf_units then buf_units.okei else 0.

    hSAXWriter:START-ELEMENT ("GoodsLocalItem") no-error.

    hSAXWriter:WRITE-DATA-ELEMENT("ExtCode" , string(buf_code.code, fill("9", p-long-code)) ) no-error.

    hSAXWriter:WRITE-DATA-ELEMENT("GoodsItemCode" , string(buf_ext-classif.charkey_one) ) no-error.
    hSAXWriter:WRITE-DATA-ELEMENT("Name" , buf_code.codename) no-error.
    hSAXWriter:WRITE-DATA-ELEMENT("LatinName" , buf_code.misc1) no-error.
    hSAXWriter:WRITE-DATA-ELEMENT("VAT" , buf_code.misc2) no-error.
    hSAXWriter:WRITE-DATA-ELEMENT("AddData", "UNIT_TYPE=" + string(v-units-okei) ) no-error.
    hSAXWriter:WRITE-DATA-ELEMENT("UnitType" , string(v-units-okei) ) no-error.

    hSAXWriter:WRITE-DATA-ELEMENT("IsActive" , if buf_code.status_ = 0 then "Yes" else "No") no-error.
    hSAXWriter:WRITE-DATA-ELEMENT("EffectiveDate" , "2010-01-01") no-error.
    hSAXWriter:WRITE-DATA-ELEMENT("ExpirationDate" , "2100-01-01") no-error.
    
    hSAXWriter:end-ELEMENT ("GoodsLocalItem") no-error.
  end.
end.

hSAXWriter:end-ELEMENT ("GoodsLocalItems") no-error.
hSAXWriter:end-ELEMENT ("GoodsLocalSet") no-error.

hSAXWriter:end-ELEMENT ("GoodsLocalSets") no-error.    
hSAXWriter:end-ELEMENT ("GoodsLocalFile") no-error.
hSAXWriter:end-document() no-error.
  

if p-place = 2 then
do:
    if p-directory <> "":U
        then
    do:

        run ftp-send in this-procedure (input (file_name )) no-error.
        if error-status:error
            then
        do:
                  &scop my-message substitute("Ошибка отправки по FTP: &1", return-value)
            {&display-message}.
        end.
        else
        do:
            os-delete value( file_name  ).
        end.
    end.
end.
      
procedure grp-line:
    define input parameter p-grp-code as integer.
    define output parameter p-ext-class-grp as character .
p-ext-class-grp = "".

    find first gds-grp  no-lock  where gds-grp.node-code = p-grp-code no-error.
    
    if available gds-grp  then 
    do:

        find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_gds-grp}
            and buf_ext-classif.classif-name = {&extclass_gds-grp}
            and buf_ext-classif.key#_two = p-code_system
            and buf_ext-classif.key#_three = 0
            and buf_ext-classif.key#_one =  gds-grp.node-code   no-error.
         
        if available buf_ext-classif then 
        do: 
            p-ext-class-grp = buf_ext-classif.charkey_one.
            return no-apply.
        end.

        run grp-line(input gds-grp.upper-code, output p-ext-class-grp) .
    end.



end procedure.
    
    
      
procedure ftp-send :
    define input parameter p-file-name as character        no-undo.
    
    define variable v-parameter as character no-undo.
    do
        on error undo, return error
        :

        /*Перед передачей параметра чистим ip-адрес от лишних символов*/
        p-directory = trim(trim(replace(p-directory,'ftp:',""),{&slash-char}),{&back-slash-char}).
        /*Передача параметров*/
        v-parameter = p-directory + {&delim-par} +
            p-login + {&delim-par} +
            p-password + {&delim-par} +
            string({&INTERNET_FLAG_PASSIVE}) + {&delim-par} + ''
            +
            p-file-name  + {&delim-par} +
            /*p-ftp-target-dir + {&slash-char} +*/ p-file-name + {&delim-par} +
            string(no) + {&delim-par} + log-file-name.
                   

        run gbl/ftp-put.p   ( input this-procedure:handle
            ,input this-procedure:handle
            , input p-log-handle
            , input v-parameter
            ) no-error.


    end. /* do on error */
end procedure. /* ftp-send */
  
  
  
