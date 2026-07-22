block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:34:24 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-loyal-p.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/exp-loyal-p.p $":U .
define variable vss-description as character no-undo init "Процедура выгрузки.Лояльность".

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
define input parameter p-izm-N as integer no-undo.
define input parameter p-code_pool as char no-undo.
define input parameter p-type-exp as integer no-undo.
define input parameter p-long-code as integer no-undo.
define input parameter p-cb-spl-ptrl as character no-undo.

define variable v-localcode   as char      no-undo.
define variable v-is-petrol   as logical   no-undo.
define variable v-is-pieces   as logical   no-undo.
define variable xml-date-file as character no-undo.
define variable xml-time-file as character no-undo.
DEFINE VARIABLE file_name     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-date-file   AS CHARACTER NO-UNDO.
DEFINE VARIABLE log-file-name AS CHARACTER NO-UNDO. 
define variable v-vat-pc      as decimal   no-undo.
define variable v-gds-type as character no-undo.
define buffer buf_ext-classif for ext-classif.
define buffer buf_goods       for goods.
define buffer buf_goods-attr  for goods-attr.
define buffer buf_c-goods for c-goods.
DEFINE VARIABLE MyUUID AS RAW    NO-UNDO.
DEFINE VARIABLE vGUID  AS CHARACTER NO-UNDO.
   define variable par-type as character no-undo.
define variable  lty as character no-undo.
   
    ASSIGN 
     MyUUID = GENERATE-UUID  
    vGUID  = GUID(MyUUID).

xml-date-file = STRING(YEAR(TODAY), "9999") + "-" + STRING(MONTH(TODAY), "99") + "-" + STRING(DAY(TODAY), "99").
xml-time-file = substring(string(time,"HH:MM"),1,2)  + substring(string(time,"HH:MM"),4,2) + substring(string(time,"HH:MM:SS"),7,2).
v-date-file  = STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + substring(string(time,"HH:MM"),1,2) + substring(string(time,"HH:MM"),4,2).



/*          { gbl/conf-rd.i*/
/* "'spl-lty'"             */
/* "''":U                  */
/* "''":U                  */
/* "''":U                  */
/* "''":U                  */
/* "''":U                  */
/* "''":U                  */
/* NO                      */
/* lty                     */
/* par-type                */
/* NO-ERROR                */
/* }                       */
/*                         */
/*                         */
 
if p-place = 1 then
do:
    log-file-name = p-directory + "GOODSANDGROUPS_Import_AddOrUpdate_.txt":U.
    file_name = p-directory + 'GOODSANDGROUPS_Import_AddOrUpdate_':U + v-date-file  + '.xml'.
     
end.

if p-place = 2 then
do:

    file_name = session:temp-directory + 'GOODSANDGROUPS_Import_AddOrUpdate_':U + v-date-file  + '.xml'.
    assign
        log-file-name = "GOODSANDGROUPS_Import_AddOrUpdate_.log"
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
hSAXWriter:encoding = "UTF-8":U.
hSAXWriter:start-document() no-error.


hSAXWriter:START-ELEMENT ("Report") no-error.

 hSAXWriter:START-ELEMENT ("Header") no-error.
hSAXWriter:WRITE-data-ELEMENT("Guid" , vGUID ) no-error.     
hSAXWriter:WRITE-data-ELEMENT("ReportType" , "GoodsAndGroups" ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("ReportDate" , xml-date-file ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("Time_Report" , string(integer (xml-time-file))) no-error.
hSAXWriter:WRITE-data-ELEMENT("PartnerCode" , p-cb-spl-ptrl ) no-error.
hSAXWriter:WRITE-DATA-ELEMENT("DataSetName" , p-code_pool ) no-error.
hSAXWriter:end-ELEMENT ("Header") no-error.

hSAXWriter:START-ELEMENT ("Body") no-error.

hSAXWriter:START-ELEMENT ("Groups") no-error.
  for each gds-grp: 
  if  gds-grp.upper-code <> 0  then do:
       
        
        hSAXWriter:START-ELEMENT ("Group") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("GrpCode" ,  string(gds-grp.node-code )  ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("RefToUpper", string(gds-grp.upper-code) ) no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("Name" , gds-grp.node-name   ) no-error.   
        hSAXWriter:end-ELEMENT ("Group") no-error.

    end.
    else do: 
        
               
        hSAXWriter:START-ELEMENT ("Group") no-error.
        hSAXWriter:WRITE-DATA-ELEMENT("GrpCode" ,  string(gds-grp.node-code )  ) no-error.
/*        hSAXWriter:WRITE-DATA-ELEMENT("RefToUpper", string(gds-grp.upper-code) ) no-error.*/
        hSAXWriter:WRITE-DATA-ELEMENT("Name" , gds-grp.node-name   ) no-error.   
        hSAXWriter:end-ELEMENT ("Group") no-error.
        
        
        end.
        end.
 hSAXWriter:end-ELEMENT ("Groups") no-error.




hSAXWriter:START-ELEMENT ("Goods") no-error .



    if p-type-exp = 1 then 
    do:
        for each buf_goods  : 
                if buf_goods.gds-type = "т"  then v-gds-type = "g".
                if buf_goods.gds-type = "у" then v-gds-type = "s".
              { gbl/pgtxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-vat-pc no-error}
                
            if not  can-find (first goods-attr where goods-attr.gds-code = buf_goods.gds-code and  goods-attr.attr-code = {&attr-office-type})
            
                /*            goods-attr.attr-value = {&prop-list-attr-office-type})*/



                then 
            do:  
            
                
                
                hSAXWriter:START-ELEMENT ("Good") no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Gds-code" , string(buf_goods.gds-code, fill("9", p-long-code))  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Artic" , string(buf_goods.artic)  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Status" , string(buf_goods.stts)  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("GrpCode" , string(buf_goods.grp-code)  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Units" , buf_goods.unit-base  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("VAT" , string(v-vat-pc)  ) no-error.
                
                hSAXWriter:WRITE-DATA-ELEMENT("Type" , v-gds-type  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Name" , buf_goods.gds-name  ) no-error. 
                 hSAXWriter:WRITE-DATA-ELEMENT("LabelName" , buf_goods.engl-name) no-error.
                hSAXWriter:end-ELEMENT ("Good") no-error.
            end.
        end. 
    end.


if p-type-exp = 2 then 
do:

    for each buf_goods:
        
                      { gbl/pgtxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-vat-pc no-error}
        
        
         if buf_goods.gds-type = "т"  then v-gds-type = "g".
                if buf_goods.gds-type = "у" then v-gds-type = "s".
        if not can-find ( goods-attr where goods-attr.gds-code = buf_goods.gds-code and goods-attr.attr-code = {&attr-office-type}) then
        do:
       
            if   can-find  (first buf_c-goods where buf_c-goods.gds-code = buf_goods.gds-code and buf_c-goods.corr-date >= (today - p-izm-N) ) then 
            do:

       
              
                hSAXWriter:START-ELEMENT ("Good") no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Gds-code" , string(buf_goods.gds-code, fill("9", p-long-code))  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Status" , string(buf_goods.stts)  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("GrpCode" , string(buf_goods.grp-code)  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Units" , buf_goods.unit-base  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("VAT" , string(v-vat-pc)  ) no-error.
                
                hSAXWriter:WRITE-DATA-ELEMENT("Type" , v-gds-type  ) no-error.
                hSAXWriter:WRITE-DATA-ELEMENT("Name" , buf_goods.gds-name  ) no-error. 
                hSAXWriter:WRITE-DATA-ELEMENT("LabelName" , buf_goods.engl-name) no-error.
                hSAXWriter:end-ELEMENT ("Good") no-error.
            end.
        end.
    end.

end.
hSAXWriter:end-ELEMENT ("Goods") no-error.

hSAXWriter:end-ELEMENT ("Body") no-error.
hSAXWriter:end-ELEMENT ("Report") no-error. 
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








