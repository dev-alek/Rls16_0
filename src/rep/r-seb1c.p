block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Бензиновый отчет по себестоимости

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/15/05
*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Бензиновый отчет по себестоимости".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ str/lib-trn.i  }
{ rep/rep-bt.i   }
{ gbl/waitfram.i }
 do
 on error undo, return error return-value
 :

define temp-table temp_dbflib_field no-undo
    field col-num           as integer
    field field-name        as character    format "x(32)"
    field data-type         as character
    field field-decimals    as integer
    field dbfield-name      as character    format "x(11)"
    field field-handle      as handle
    field field-length      as integer      format ">>>9"

    index field-name        is primary unique
        field-name
    index col_
        col-num    
.
define temp-table temp_dbflib_data no-undo
    field col-num           as integer
    field record-number as integer
    field field-name    as character
    field data-value    as character

    index pi is primary unique
        record-number
        field-name
    index col_
        col-num 
.
define variable v-dbflib-reclength      as integer      no-undo.
define variable v-field-amount          as integer      no-undo.
define stream dbf-stream.

define temp-table tt-seb no-undo
  field   DATAS           as date
  field   NAMEA           as character
  field   AZS             as character
  field   KODVO           as character
  field   NAMET           as character
  field   TOVAR           as character
  field   SUMMA           as decimal decimals 2
  field   NAMEP           as character
  field   POLUCH          as character
  field   chk-qnty        as decimal
  index pi as primary unique
    DATAS AZS KODVO TOVAR POLUCH
.

define buffer buf_tt-seb for tt-seb .
define buffer buf2_tt-seb for tt-seb .

define temp-table tt-fbr no-undo
  field comp-gds-code     as integer
  field ingr-gds-code     as integer
  field ingr-gds-name     as character
  field comp-qnty         as decimal
  field inqr-qnty         as decimal
  index pi as primary unique
    comp-gds-code ingr-gds-code
.

def buffer buf_clients for ub.clients .
def buffer This_Object for ub.clients .
def buffer buf_goods   for ub.goods .

def var i as int no-undo.

/*-----------------------------------------------------------------------------------------------------------------------*/


define variable paris-petrolium as   logical            no-undo.
define variable paris-pieces    as   logical            no-undo.
define temp-table tt-gds-list no-undo like ub.goods.

run waitfram-show ( "Ждите..." ) .

for each tt-gds-list : delete tt-gds-list. end.

for each buf_goods no-lock where buf_goods.gds-type = "т" :
  { str/is-petrl.i
    buf_goods.artic
    buf_goods.prod-type
    buf_goods.prod-code
    paris-petrolium
    paris-pieces
    }
      if paris-petrolium
      then do :
      end.
      else do :
          create tt-gds-list.
          BUFFER-COPY buf_goods TO tt-gds-list.
      end.
end.


empty temp-table tt-seb .



for each obj-list :
  run rep/rpychk0.p ( input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ? /*p-date-from*/
                        ,input ? /*p-date-to*/
                        ,input X-date-Start /*p-shift-date-from*/
                        ,input x-Date-End /*p-shift-date-to*/
                        ,input 1 /*p-shift-num-start*/
                        ,input 999 /*p-shift-num-end*/
                        ,input ? /*p-inkas-code*/
                        ).
  run make-tt.
end. /* obj-list */

run dbflib-init in this-procedure.

run dbflib-add-field in this-procedure (
                          input 1
                        , input "DATAS"
                        , input 8
                        , input "date":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 2
                        , input "NAMEA"
                        , input 100
                        , input "character":U
                        , input 0
                    ).  
run dbflib-add-field in this-procedure (
                          input 3
                        , input "AZS"
                        , input 25
                        , input "character":U
                        , input 0
                    ).  
run dbflib-add-field in this-procedure (
                          input 4
                        , input "KODVO"
                        , input 10
                        , input "character":U
                        , input 0
                    ).                                                          
run dbflib-add-field in this-procedure (
                          input 5
                        , input "NAMET"
                        , input 100
                        , input "character":U
                        , input 0
                    ).  
run dbflib-add-field in this-procedure (
                          input 6
                        , input "TOVAR"
                        , input 25
                        , input "character":U
                        , input 0
                    ).  
run dbflib-add-field in this-procedure (
                          input 7
                        , input "SUMMA"
                        , input 15
                        , input "decimal":U
                        , input 2
                    ).
run dbflib-add-field in this-procedure (
                          input 8
                        , input "NAMEP"
                        , input 100
                        , input "character":U
                        , input 0
                    ).  
run dbflib-add-field in this-procedure (
                          input 9
                        , input "POLUCH"
                        , input 25
                        , input "character":U
                        , input 0
                    ).
i = 0 .
for each tt-seb no-lock where tt-seb.KODVO <> "spi-prvo" break by tt-seb.DATAS by tt-seb.AZS by tt-seb.KODVO by tt-seb.TOVAR :
  find first buf_goods no-lock where buf_goods.gds-code = integer(tt-seb.TOVAR) .
  find first obj-list no-lock where obj-list.obj-name = tt-seb.NAMEA .
  find first ub.recipe no-lock where
             ub.recipe.prod-type = buf_goods.prod-type
         and ub.recipe.prod-code = buf_goods.prod-code
         and ub.recipe.artic     = buf_goods.artic
         and
           (
           ( ub.recipe.obj-type  = obj-list.obj-type
         and ub.recipe.obj-code  = obj-list.obj-code
           )
          or
           ( ub.recipe.obj-type  = "":U
         and ub.recipe.obj-code  = 0
           )
           )
         no-error.
  if available ub.recipe then next .
  i = i + 1.
  run dbflib-add-data in this-procedure (
                          input 1
                        , input i
                        , input "DATAS"
                        , input string(tt-seb.DATAS)
                    ).
  run dbflib-add-data in this-procedure (
                          input 2
                        , input i
                        , input "NAMEA"
                        , input tt-seb.NAMEA
                    ). 
  run dbflib-add-data in this-procedure (
                          input 3
                        , input i
                        , input "AZS"
                        , input tt-seb.AZS
                    ). 
  run dbflib-add-data in this-procedure (
                          input 4
                        , input i
                        , input "KODVO"
                        , input tt-seb.KODVO
                    ). 
  run dbflib-add-data in this-procedure (
                          input 5
                        , input i
                        , input "NAMET"
                        , input tt-seb.NAMET
                    ). 
  run dbflib-add-data in this-procedure (
                          input 6
                        , input i
                        , input "TOVAR"
                        , input tt-seb.TOVAR
                    ). 
  run dbflib-add-data in this-procedure (
                          input 7
                        , input i
                        , input "SUMMA"
                        , input string(tt-seb.SUMMA)
                    ). 
  run dbflib-add-data in this-procedure (
                          input 8
                        , input i
                        , input "NAMEP"
                        , input tt-seb.NAMEP
                    ). 
  run dbflib-add-data in this-procedure (
                          input 9
                        , input i
                        , input "POLUCH"
                        , input tt-seb.POLUCH
                    ).                                  
end.

run dbflib-write-dbf in this-procedure (
    input "sebestst.dbf":U
  , input i
) no-error.
if error-status :error
then do:
    message
             vss-workfile vss-revision vss-description
        skip(1)
        skip "Ошибка записи файла формата dbf."
        skip return-value
        skip trim( error-status :get-message( 1 ) )
             trim( error-status :get-message( 2 ) )
             trim( error-status :get-message( 3 ) )
    view-as alert-box error.
    undo, return error.
end.

run waitfram-hide .

message "Готово! Данные выгружены в файл sebestst.dbf в рабочую папку." view-as alert-box .
                                        
/*run make-dbf (input buffer tt-seb:handle) .*/

end.

/* *************************************************************************************************** */

procedure make-tt :
  do
  on error undo, return error return-value
  :

  define buffer buf_shift-obj for ub.shift-obj.

  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf2_doc-line for ub.doc-line.
  define buffer buf_chk-doc for ub.chk-doc.
  define buffer buf_chk-gds for ub.chk-gds.
  define buffer buf_chk-gds-pay for ub.chk-gds-pay.
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_fbr-doc for ub.fbr-doc .
  define buffer buf_comp_fbr-line for ub.fbr-line.
  define buffer buf_ingr_fbr-line for ub.fbr-line.
  define buffer buf_ot-line for ub.ot-line .
  
  define variable v-pay-code as character no-undo .
  define variable v-vat-pc as decimal no-undo .
  
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End 
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   {&fact}
                                 and  buf_trn-doc.ext-doc-type  =   {&TDEDT_Ras_Vnesh_Kass},
  each buf_chk-doc no-lock where buf_chk-doc.out-code = buf_trn-doc.doc-code,
  each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code,                              
  each buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-gds.doc-code
                                 and buf_chk-gds-pay.line-num = buf_chk-gds.line-num
                                 and buf_chk-gds-pay.b-code   = buf_chk-gds.b-code,
  first buf_bar-code no-lock where buf_bar-code.b-code  = buf_chk-gds-pay.b-code,
  first tt-gds-list no-lock where tt-gds-list.gds-code = buf_bar-code.gds-code:
    if trim(buf_chk-doc.d-card) > ""
    then do :
      if buf_chk-gds-pay.pay-code = 1 then v-pay-code = "Т001" .
      else
      if buf_chk-gds-pay.pay-code = 2975 then v-pay-code = "Т002" .
      else
      v-pay-code = string(buf_chk-gds-pay.pay-code, "9999") .
      if v-pay-code = "Т001" and buf_chk-gds-pay.tot-r-b <= 0.01 then v-pay-code = string(buf_chk-gds-pay.pay-code, "9999") .
    end.
    else do :
      v-pay-code = string(buf_chk-gds-pay.pay-code, "9999") .
    end.
    
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = v-pay-code
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End      
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")   
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = v-pay-code                
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = ""
        tt-seb.NAMEP = ""
      .
    end. 
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_chk-gds-pay.eff-doc-qnty . 
    
    find first buf_doc-line no-lock where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                                      and buf_doc-line.artic      = tt-gds-list.artic
                                      and buf_doc-line.prod-type  = tt-gds-list.prod-type
                                      and buf_doc-line.prod-code  = tt-gds-list.prod-code
                                      no-error .
    if available buf_doc-line
    then do :
      find last buf_ot-line where  buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                    buf_ot-line.artic        =  buf_doc-line.artic                and
                                    buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                    buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                    buf_ot-line.obj-code     =  obj-list.obj-code      and
                                    buf_ot-line.obj-type     =  obj-list.obj-type      and
                                    buf_ot-line.sum-type     = {&arh-cost} use-index pi no-lock no-error.
      assign
        v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0 
        tt-seb.SUMMA = tt-seb.SUMMA + (buf_chk-gds-pay.eff-doc-qnty * buf_doc-line.price-rubl / (1 + v-vat-pc))
      .
    end.
  end.
  
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End 
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   {&fact}
                                 and  buf_trn-doc.ext-doc-type  =   {&TDEDT_Ras_Perem},
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:  
    
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = "9999"
                                       and  tt-seb.POLUCH = string(buf_trn-doc.cli-code, "99999999999")
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End      
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")   
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = "9999"                
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = string(buf_trn-doc.cli-code, "99999999999")
        tt-seb.NAMEP = buf_trn-doc.cli-name
      .
    end. 
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_doc-line.fact-qnty .
    find last  buf_ot-line where buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                  buf_ot-line.artic        =  buf_doc-line.artic                and
                                  buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                  buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                  buf_ot-line.obj-code     =  obj-list.obj-code      and
                                  buf_ot-line.obj-type     =  obj-list.obj-type      and
                                  buf_ot-line.sum-type     = {&arh-cost} use-index pi no-lock no-error.
    assign
      v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0 
      tt-seb.SUMMA = tt-seb.SUMMA + (buf_doc-line.fact-qnty * buf_doc-line.price-rubl / (1 + v-vat-pc))
    .
  end.
  
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End 
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   {&fact}
                                 and  buf_trn-doc.ext-doc-type  =   {&TDEDT_Spi_Vnesh},
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:  
    
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = "9998"
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End      
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")   
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = "9998"                
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = ""
        tt-seb.NAMEP = ""
      .
    end. 
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_doc-line.fact-qnty .
    find last buf_ot-line where  buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                  buf_ot-line.artic        =  buf_doc-line.artic                and
                                  buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                  buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                  buf_ot-line.obj-code     =  obj-list.obj-code      and
                                  buf_ot-line.obj-type     =  obj-list.obj-type      and
                                  buf_ot-line.sum-type     = {&arh-cost} use-index pi no-lock no-error.
    assign
      v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0
      tt-seb.SUMMA = tt-seb.SUMMA + (buf_doc-line.fact-qnty * buf_doc-line.price-rubl /(1 + v-vat-pc))
    .
  end.
  
  for each buf_fbr-doc no-lock where  buf_fbr-doc.shift-date    >=  x-Date-Start
                                 and  buf_fbr-doc.shift-date    <=  x-Date-End 
                                 and  buf_fbr-doc.obj-type      =   obj-list.obj-type
                                 and  buf_fbr-doc.obj-code      =   obj-list.obj-code
                                 and  buf_fbr-doc.status_       =   {&fact}:
    for each buf_comp_fbr-line no-lock where buf_comp_fbr-line.doc-code = buf_fbr-doc.doc-code
                                         and buf_comp_fbr-line.is-comp = yes,
    first buf_goods of buf_comp_fbr-line:     
      for each buf_ingr_fbr-line no-lock where buf_ingr_fbr-line.doc-code = buf_fbr-doc.doc-code
                                           and buf_ingr_fbr-line.is-comp = no
                                           and buf_ingr_fbr-line.recipe-code = buf_comp_fbr-line.recipe-code,
      first tt-gds-list no-lock where tt-gds-list.artic     = buf_ingr_fbr-line.artic
                                  and tt-gds-list.prod-type = buf_ingr_fbr-line.prod-type
                                  and tt-gds-list.prod-code = buf_ingr_fbr-line.prod-code :
        find first tt-fbr no-lock where tt-fbr.comp-gds-code = buf_goods.gds-code
                                    and tt-fbr.ingr-gds-code = tt-gds-list.gds-code
                                    no-error .
        if not available tt-fbr
        then do :
          create tt-fbr .
          assign
            tt-fbr.comp-gds-code = buf_goods.gds-code
            tt-fbr.ingr-gds-code = tt-gds-list.gds-code
            tt-fbr.ingr-gds-name = tt-gds-list.gds-name
          .         
        end. 
        assign
          tt-fbr.comp-qnty = tt-fbr.comp-qnty + buf_comp_fbr-line.fact-qnty
          tt-fbr.inqr-qnty = tt-fbr.inqr-qnty + buf_ingr_fbr-line.fact-qnty 
        .                                                                
      end.                                       
    end.                          
  end.     
  
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End 
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   {&fact}
                                 and  buf_trn-doc.ext-doc-type  =   {&TDEDT_Spi_Prvo},
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:  
    
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = "spi-prvo"
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End      
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")   
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = "spi-prvo"                
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = ""
        tt-seb.NAMEP = ""
      .
    end. 
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_doc-line.fact-qnty .
    find last buf_ot-line where  buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                  buf_ot-line.artic        =  buf_doc-line.artic                and
                                  buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                  buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                  buf_ot-line.obj-code     =  obj-list.obj-code      and
                                  buf_ot-line.obj-type     =  obj-list.obj-type      and
                                  buf_ot-line.sum-type     = {&arh-cost} use-index pi no-lock no-error.
    assign
      v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0
      tt-seb.SUMMA = tt-seb.SUMMA + (buf_doc-line.fact-qnty * buf_doc-line.price-rubl / (1 + v-vat-pc))
    .
                                                               
  end.    
  
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End 
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   {&fact}
                                 and  buf_trn-doc.ext-doc-type  =   {&TDEDT_Peresort},
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
                              and buf_doc-line.fact-qnty < 0,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:
    find first ub.recipe no-lock where
               ub.recipe.prod-type = buf_doc-line.prod-type
           and ub.recipe.prod-code = buf_doc-line.prod-code
           and ub.recipe.artic     = buf_doc-line.artic
           and
             (
             ( ub.recipe.obj-type  = obj-list.obj-type
           and ub.recipe.obj-code  = obj-list.obj-code
             )
            or
             ( ub.recipe.obj-type  = "":U
           and ub.recipe.obj-code  = 0
             )
             )
           no-error.
    if available ub.recipe
    then do :
      find first ub.parts-root no-lock where ub.parts-root.doc-code = buf_trn-doc.doc-code
                                         and ub.parts-root.orig-gds-code = tt-gds-list.gds-code
                                         no-error .
      if available ub.parts-root
      then do :
        for each buf_tt-seb exclusive-lock where buf_tt-seb.DATAS = x-Date-End
                                             and buf_tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                             and buf_tt-seb.TOVAR = string(ub.parts-root.orig-gds-code, "99999999999") :
          find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                             and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                             and  tt-seb.TOVAR = string(ub.parts-root.gds-code, "99999999999")
                                             and  tt-seb.KODVO = buf_tt-seb.KODVO
                                             no-error .      
          if available tt-seb
          then do :
            find first ub.goods no-lock where ub.goods.gds-code = ub.parts-root.gds-code .
            find first buf2_doc-line no-lock where buf2_doc-line.doc-code   = buf_doc-line.doc-code
                                               and buf2_doc-line.artic      = ub.goods.artic
                                               and buf2_doc-line.prod-type  = ub.goods.prod-type
                                               and buf2_doc-line.prod-code  = ub.goods.prod-code
                                               and buf2_doc-line.fact-qnty >= 0
                                               no-error .
            if available buf2_doc-line
            then do :
              find first ub.parts no-lock where ub.parts.artic      = buf2_doc-line.artic
                                            and ub.parts.prod-type  = buf2_doc-line.prod-type
                                            and ub.parts.prod-code  = buf2_doc-line.prod-code
                                            and ub.parts.in-code    = buf_trn-doc.doc-code
                                            and ub.parts.out-code   = {&output-code}
                                            no-error .
              if available ub.parts
              then do :                              
                assign
                  buf_tt-seb.chk-qnty = buf_tt-seb.chk-qnty + ((abs(buf_doc-line.fact-qnty) / buf2_doc-line.fact-qnty) * ub.parts.fact-qnty)
                  buf_tt-seb.SUMMA = buf_tt-seb.SUMMA + (tt-seb.SUMMA * (ub.parts.fact-qnty / tt-seb.chk-qnty))
                  tt-seb.chk-qnty = tt-seb.chk-qnty - ub.parts.fact-qnty
                  tt-seb.SUMMA = tt-seb.SUMMA - (tt-seb.SUMMA * (ub.parts.fact-qnty / tt-seb.chk-qnty))
                .
              end .
            end .                                   
          end .                                                  
        end .                       
      end .                                   
    end .                         
  end .                                  

  for each buf_tt-seb no-lock where buf_tt-seb.KODVO <> "spi-prvo" :
    for each tt-fbr no-lock where tt-fbr.comp-gds-code = integer(buf_tt-seb.TOVAR) :
      find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                         and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                         and  tt-seb.TOVAR = string(tt-fbr.ingr-gds-code, "99999999999")
                                         and  tt-seb.KODVO = buf_tt-seb.KODVO
                                         no-error .
      if not available tt-seb
      then do :
        create tt-seb.
        assign
          tt-seb.DATAS = x-Date-End      
          tt-seb.AZS   = string(obj-list.obj-code, "99999999999")   
          tt-seb.TOVAR = string(tt-fbr.ingr-gds-code, "99999999999")
          tt-seb.KODVO = buf_tt-seb.KODVO                
          tt-seb.NAMEA = obj-list.obj-name
          tt-seb.NAMET = tt-fbr.ingr-gds-name
          tt-seb.POLUCH = ""
          tt-seb.NAMEP = ""
        .
      end . 
      
      find first buf2_tt-seb no-lock where  buf2_tt-seb.DATAS = x-Date-End
                                       and  buf2_tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  buf2_tt-seb.TOVAR = string(tt-fbr.ingr-gds-code, "99999999999")
                                       and  buf2_tt-seb.KODVO = "spi-prvo"
                                       no-error .
      if available buf2_tt-seb
      then do :
        assign
          tt-seb.SUMMA = tt-seb.SUMMA + (buf2_tt-seb.SUMMA * buf_tt-seb.chk-qnty / buf2_tt-seb.chk-qnty * (tt-fbr.inqr-qnty / tt-fbr.comp-qnty))
        .
      end.                                  
    end.
  end.                    
  
                                  
  end. /* do */
end procedure. /* make-tt */
 
procedure make-dbf :
  define input parameter p-tt-hndl as handle .
   
end.

procedure dbflib-write-dbf :
define input parameter p-filename       as character        no-undo.
define input parameter p-record-amount  as integer          no-undo.

    define variable v-date          as date         no-undo.
    define variable v-string-value  as character    no-undo.
    define variable raw-value       as raw          no-undo.
    define variable v-record-count  as integer      no-undo.

    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
on error undo, return error
:
    output stream dbf-stream to value( p-filename ) binary convert target 'IBM866'.
    put stream dbf-stream
        control "~003":U
    .
    /* bytes 1-3: Date of last update */
    run dbflib-makebinary (
          input year( today ) - 2000
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    run dbflib-makebinary (
        month( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    run dbflib-makebinary (
          input day( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* Number of records (bytes 4-7) as a 4-byte binary number: */
    run dbflib-makebinary (
          input p-record-amount
        , input 4
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* no of bytes in the header (bytes 8-9) */
    run dbflib-makebinary (
          input ( 32 + 32 * v-field-amount + 1 )
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* bytes 10-11: record length */
    run dbflib-makebinary (
          input v-dbflib-reclength + 1
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* bytes 12-31: null */
    put stream dbf-stream control null( 20 ).

    /* now the field descriptions */
    for each buf_temp_dbflib_field use-index col_
    :
        put stream dbf-stream control
            buf_temp_dbflib_field.dbfield-name
            null( 11 - length( buf_temp_dbflib_field.dbfield-name ) )
        .  /* 11 bytes null filled */
        case buf_temp_dbflib_field.data-type:
            when "character":U
            then do:
                put stream dbf-stream "C".
            end.
            when "integer":U
            or when "decimal"
            then do:
                put stream dbf-stream "N".
            end.
            when "logical":U
            then do:
                put stream dbf-stream "L".
            end.
            when "date":U
            then do:
                put stream dbf-stream "D".
            end.
            otherwise do:
                undo, return error substitute("Unknown field type for &1: &2",
                                                buf_temp_dbflib_field.field-handle:name,
                                                buf_temp_dbflib_field.data-type).
            end.
        end case.

        put stream dbf-stream control
            null( 4 )                      /* reserved */
            chr( buf_temp_dbflib_field.field-length )    /* field length in binary */
        .
        if buf_temp_dbflib_field.field-decimals = 0
        then do:
            put stream dbf-stream control null.
        end.
        else do:
            put stream dbf-stream control
                chr( buf_temp_dbflib_field.field-decimals ) /* decimal count in binary */
            .
        end.
        put stream dbf-stream control
            null(2)                      /* reserved */
            chr(1)                       /* work area id */
            null(11)                     /* reserved etc. */
       .
    end. /* of field specifications */
    put stream dbf-stream control
        chr(13)           /* field terminator */
    .
    do v-record-count = 1 to p-record-amount
    on error undo, return error
    :
        for each buf_temp_dbflib_data
           where buf_temp_dbflib_data.record-number = v-record-count use-index col_
        :
            put stream dbf-stream
                " "
            . /* delete flag */
            find first buf_temp_dbflib_field
            where buf_temp_dbflib_field.field-name = buf_temp_dbflib_data.field-name
            no-error.
            if available buf_temp_dbflib_field
            then do:
                case buf_temp_dbflib_field.data-type
                :
                    when "logical":U
                    then do:
                        put stream dbf-stream unformatted
                            ( if buf_temp_dbflib_data.data-value = "yes":U
                            then "T":U
                            else "F":U )
                        .
                    end.
                    when "date":U
                    then do:
                        assign
                            v-date = date( buf_temp_dbflib_data.data-value )
                        .
                        put stream dbf-stream unformatted
                            year( v-date )
                            month( v-date ) format "99"
                            day( v-date ) format "99"
                        .
                    end.
                    when "decimal":U
                    or when "integer":U
                    then do:        /* remove thousands seperators, replace decimal separators with dot */
                        if session:numeric-format = "EUROPEAN":U
                        then do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ), ".":U, "":U )
                                v-string-value = replace( v-string-value, ",":U, ".":U )
                            .
                        end.
                        else do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ),",","")
                            .
                        end.
                        put stream dbf-stream unformatted
                            v-string-value
                            fill( " ":U, buf_temp_dbflib_field.field-length - 1 - length( v-string-value ) )
                        .
                    end.
                    otherwise do:
                        put stream dbf-stream unformatted
                            string( buf_temp_dbflib_data.data-value )
                            fill( " ", buf_temp_dbflib_field.field-length - 1 - length( string( buf_temp_dbflib_data.data-value ) ) )
                        .
                    end.
                end case.       /* case buf_temp_dbflib_field.data-type */
            end.        /* if available buf_temp_dbflib_field */
        end.        /* for each buf_temp_dbflib_data */
    end.        /* do */
    output stream dbf-stream close.
end.
end procedure. /* dbflib-write-dbf */

/* This routine converts a Progress integer to a binary
    representation. No "C" needed!

    Input parameters:

    - number to be converted
    - no of desired bytes

    Output parameter

    - binary representation of number as a raw variable
    with the correct length

*/
PROCEDURE dbflib-makebinary:
define input parameter anumm#     as integer      no-undo. /* number */
define input parameter abyte#     as integer      no-undo. /* no of desired bytes */
define output parameter raw-value as raw          no-undo. /* result of conversion */

    define variable acoun#    as integer      no-undo.
do
on error undo, return error
:
    assign
        length( raw-value ) = abyte#
    .
    if anumm# <0
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": This routine works for positive integers only."
            skip "Received value of" anumm# "is invalid."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    if anumm# > 0
    and anumm# modulo anumm# / EXP( anumm#, abyte#) > 256
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": received number" anumm#
            skip "does not fit in" abyte# "bytes."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    do acoun# = abyte# to 1 by -1
    on error undo, return error
    :
        put-byte( raw-value, acoun# ) = int( truncate( anumm# / EXP( 256, acoun# - 1 ), 0 ) ).
        if anumm# ne 0
        then do:
            assign
                anumm# = anumm# modulo EXP( 256, acoun# - 1 )
            .
        end.
    end.
end.
END PROCEDURE. /* dbflib-makebinary */

/*==========================================================================*/
procedure dbflib-init :

    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
:
    empty temp-table buf_temp_dbflib_field.
    empty temp-table buf_temp_dbflib_data.
    assign
        v-dbflib-reclength = 0
        v-field-amount     = 0
    .
end.
end procedure. /* dbflib-init */
/*==========================================================================
Input:
    p-field-name     as character -
    p-field-length   as integer   -
    p-data-type      as character - "character":U, "integer":U, "logical":U, "date":U
    p-field-decimals as integer   -

*/
procedure dbflib-add-field :
define input parameter p-col-num        as integer          no-undo.  
define input parameter p-field-name     as character        no-undo.
define input parameter p-field-length   as integer          no-undo.
define input parameter p-data-type      as character        no-undo.
define input parameter p-field-decimals as integer          no-undo.

    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
do
for buf_temp_dbflib_field
on error undo, return error
:
    find first buf_temp_dbflib_field
         where buf_temp_dbflib_field.field-name       = p-field-name
    no-error.
    if not available buf_temp_dbflib_field
    then do:
        create buf_temp_dbflib_field.
        assign
            buf_temp_dbflib_field.col-num          = p-col-num
            buf_temp_dbflib_field.field-name       = p-field-name
            buf_temp_dbflib_field.field-length     = p-field-length
            buf_temp_dbflib_field.data-type        = p-data-type
            buf_temp_dbflib_field.field-decimals   = p-field-decimals
            buf_temp_dbflib_field.dbfield-name     = caps( replace( substring( p-field-name, 1, 11 ), "-":U, "_":U ) )
            v-dbflib-reclength                     = v-dbflib-reclength + buf_temp_dbflib_field.field-length
            v-field-amount                         = v-field-amount + 1
        .
    end.
end.
end procedure. /* dbflib-add-field */


/*==========================================================================*/
procedure dbflib-add-data :
define input parameter p-col-num        as integer          no-undo.  
define input parameter p-record-number  as integer          no-undo.
define input parameter p-field-name     as character        no-undo.
define input parameter p-data-value     as character        no-undo.

    define buffer buf_temp_dbflib_data      for temp_dbflib_data.
do
for buf_temp_dbflib_data
on error undo, return error
:
    find first buf_temp_dbflib_data
         where buf_temp_dbflib_data.record-number  = p-record-number
           and buf_temp_dbflib_data.field-name     = p-field-name
    no-error.
    if not available buf_temp_dbflib_data
    then do:
        create buf_temp_dbflib_data.
        assign
            buf_temp_dbflib_data.col-num        = p-col-num
            buf_temp_dbflib_data.record-number  = p-record-number
            buf_temp_dbflib_data.field-name     = p-field-name
            buf_temp_dbflib_data.data-value     = p-data-value
        .
    end.
end.
end procedure. /* dbflib-add-data */
