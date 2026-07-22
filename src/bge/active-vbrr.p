block-level on error undo, throw.

/*

$Revision: 370d2a7b72c6, 2053, rls $
$Author: EShklyar $ Shalanin Sergey   $  
$Date: Fri Oct 18 11:02:52 2019 +0300 $ 
$Workfile: active-vbrr.p $ active-vbrr.p $
$Archive: bge/active-vbrr.p $ bge/active-vbrr.p $

Процедура выгрузки информации по пополнениям и активации для сверки с ВБРР

Автор: Шаланини Сергей
Дата создания: 22/04/2016
Author: Shalanin Sergey 
Creation date:  22/04/2016

*/

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $ SShalanin":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 18 11:02:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: active-vbrr.p $ active-vbrr.p ":U .
define variable vss-archive     as character no-undo init "$Archive: bge/active-vbrr.p $ bge/active-vbrr.p ":U .
define variable vss-description as character no-undo init "Процедура выгрузки информации по пополнениям и активации для сверки с ВБРР".

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Includes  ************************** */
{ rep/r-pychk0.i defalgo }

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i         }
{ gbl/temphost.i        }
{ gbl/getcntxt.i def    }

DEFINE INPUT PARAMETER p-log-handle AS HANDLE NO-UNDO. /* handle по которому находится процедура записи лога */
define input parameter v-obj-range   as integer   no-undo .
define input parameter v-host-code   like ub.sysconf.host-code no-undo .
define input parameter v-obj-list as character no-undo.
define input parameter date-to as date no-undo.
define input parameter date-from as date no-undo.
define input parameter v-gds-code-inf as integer no-undo.
define input parameter v-gds-code-active as integer no-undo.
define input parameter p-directory as char no-undo.
define input parameter v-code_pnpo as char no-undo.
define input parameter v-active as logical no-undo.
define input parameter v-inf-po as logical no-undo.
define input parameter p-per as integer no-undo.

define variable v-ul-day as integer no-undo.

define stream f2.
define stream f1.
define variable file_name-inf    as char    no-undo.
define variable file_name-active as char    no-undo.

define variable b-code-inf       as integer no-undo.
define variable b-code-active    as integer no-undo.

define variable v-time           as char    no-undo.
define buffer buf_goods for goods.
define variable v-code-get    as integer no-undo.
define variable v-obj-counter as integer no-undo.
define variable v-obj-type    as character no-undo.
define variable v-obj-code    as integer no-undo.

  for each temp-obj :
    delete temp-obj.
  end.
  case v-obj-range:
    when 2 then do: /* по фирме */
      run init-temphost.
      for each temp-obj where temp-obj.host-code <> v-host-code :
        delete temp-obj.
      end.
    end. /* end_of when 2 */
    when 3 then do: /* по объектам */
      do v-obj-counter = 1 to num-entries ( v-obj-list ) / 2 :
        assign
          v-obj-type =          entry( v-obj-counter * 2 - 1, v-obj-list )
          v-obj-code = integer( entry( v-obj-counter * 2    , v-obj-list ) )
        no-error .
        if error-status:error then next.
        
        find first temp-obj no-lock
             where temp-obj.obj-type = v-obj-type
               and temp-obj.obj-code = v-obj-code no-error .
        if available temp-obj then next.
        
        create temp-obj.
        assign
          temp-obj.obj-type = v-obj-type
          temp-obj.obj-code = v-obj-code
        .
      end.
    end. /* end_of when 3 */
    otherwise do:
      /* пустой перечень объектов никак не обрабатывался. */
    end.
  end case.


v-ul-day = -1 *  (INTERVAL(date( 1 , 1 , YEAR(TODAY)), today , 'days')) + 1  .

if p-per <> 0 then 
do: 
    assign
        date-from = today - p-per
        date-to   = today.
end.

if v-inf-po = yes then 
do:
    for first bar-code no-lock where bar-code.gds-code = v-gds-code-inf :

        b-code-inf = bar-code.b-code.
    end.
end.
if v-active then 
do:
    for first bar-code no-lock where bar-code.gds-code = v-gds-code-active :
    
        b-code-active = bar-code.b-code.
    end.
end.

 for each temp-obj : 
        run rep/rpychk0.p (input "r-autocu"
            ,input temp-obj.obj-type
            ,input temp-obj.obj-code
            ,input date-from                    /*p-date-from*/
            ,input date-to                    /*p-date-to*/
            ,input  ?        /*p-shift-date-from*/
            ,input ?          /*p-shift-date-to*/
            ,input ?                /*p-shift-num-start*/
            ,input ?                /*p-shift-num-end*/
            ,input ?                    /*p-inkas-code*/
            ) no-error.

        if error-status:error then
        do:
     
            return error return-value  +
                error-status:get-message(1) .
     
        
        end.
end.
define frame stav-active.

v-time =  substring(string(time,"HH:MM"),1,2)  + substring(string(time,"HH:MM"),4,2).

    
if v-inf-po = yes then 
do:
    file_name-inf = p-directory + "BPAPAY" + v-code_pnpo + "-" + v-time + "." +  string(v-ul-day) .
            output stream f1 to value(file_name-inf)   .
    
    for each temp-obj : 
        for each chk-gds-pay where chk-gds-pay.chk-date >= date-from and chk-gds-pay.chk-date  <= date-to and chk-gds-pay.obj-type = temp-obj.obj-type and chk-gds-pay.obj-code = temp-obj.obj-code and chk-gds-pay.b-code =  b-code-inf no-lock  : 

            put stream f1 unformatted
                string(chk-gds-pay.chk-date,"99.99.9999") ";" string(chk-gds-pay.chk-time,"HH:MM:SS") ";" string(integer(chk-gds-pay.tot-r-b * 100)) .  
            find first chk-pay  where chk-pay.doc-code = chk-gds-pay.doc-code no-lock no-error.
                    
            find first chk-pay-attr  where attr-code = 'CPDOC' and chk-pay-attr.doc-code = chk-gds-pay.doc-code   no-lock no-error.
            if available chk-pay-attr then 
            do:
                put stream f1 unformatted
                    ";" chk-pay-attr.attr-value  ";" skip
                    .
            end.
            else 
            do:
                put stream f1 unformatted
                    ";" ";" skip
                    .
            end.
            /*
            put stream f1 unformatted
                chk-pay.pay-card skip
                .
                */                                    
        end.
    end.
    /*        end.*/
    output stream f1 close.
    
end.

if v-active = yes then 
do:
       file_name-active = p-directory + "BPAGSP" + v-code_pnpo +  v-time + "." +  string(v-ul-day) .
        output stream f2 to value(file_name-active).
    for each temp-obj : 


     
        for each chk-gds-pay where chk-gds-pay.chk-date >= date-from and chk-gds-pay.chk-date  <= date-to and chk-gds-pay.obj-type = temp-obj.obj-type and chk-gds-pay.obj-code = temp-obj.obj-code and chk-gds-pay.b-code =  b-code-active no-lock  : 
            find first chk-doc where chk-doc.doc-code = chk-gds-pay.doc-code no-lock no-error.

            put stream f2 unformatted
                string(chk-gds-pay.chk-date,"99.99.9999") ";"  v-code_pnpo ";" string(chk-doc.doc-num) ";" "1"   skip
                .
        end.
    end.
    output stream f2 close.

end.
            