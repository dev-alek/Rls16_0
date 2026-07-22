/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение информации о товаре

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Используется в программах просмотра товара на экране, в справочнике товаров

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/nativstr.i }

FUNCTION gdsreffi_cond-keep-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_condition-keeping for ub.condition-keeping.
find first buf_condition-keeping no-lock where
         buf_condition-keeping.cond-keep-code = buf_goods.cond-keep-code no-error.
IF AVAIL buf_condition-keeping then do:
  return buf_condition-keeping.cond-keep-name.
end.
return "[!!Неизвестные УСЛОВИЯ ХРАНЕНИЯ]".
end function.

function gdsreffi_prod-grp-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_clients for ub.clients.
find first buf_clients no-lock WHERE
          buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code no-error.
if available buf_clients then do:
  return buf_clients.grp-name.
end.
return "[!!Неизвестная группа ПРОИЗВОДИТЕЛЯ]".
end function.

function gdsreffi_prod-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_clients for ub.clients.
find first buf_clients no-lock WHERE
          buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code no-error.
if available buf_clients then do:
  return buf_clients.obj-name.
end.
return "[!!Неизвестный ПРОИЗВОДИТЕЛЬ]".
end function.

function gdsreffi_prt-root-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_gds-prt for ub.gds-prt.
find first buf_gds-prt no-lock where
        buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
if available buf_gds-prt then do:
  return buf_gds-prt.node-name.
end.
return "[!!Неизвестный корень ШКАЛЫ]".
end function.

function gdsreffi_last-inv returns character ( buffer buf_goods for ub.goods
                                              ,input p-obj-type as character
                                              ,input p-obj-code as integer  ):

define variable v-last-inv-date-num as character format "X(45)" no-undo.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_trn-doc  for ub.trn-doc.
find last buf_doc-line no-lock where
          buf_doc-line.artic = buf_goods.artic
      and buf_doc-line.prod-code = buf_goods.prod-code
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.obj-code = p-obj-code
      and buf_doc-line.obj-type = p-obj-type
      and buf_doc-line.status_ = {&fact}
      and buf_doc-line.ext-doc-type = {&TDEDT_Inv} no-error.
if available buf_doc-line then do :
  find first buf_trn-doc no-lock where
             buf_trn-doc.doc-code = buf_doc-line.doc-code no-error.
  if available buf_trn-doc then do :
    assign
      v-last-inv-date-num = string(buf_trn-doc.fact-date) + " № " + buf_trn-doc.doc-code
    .
    return v-last-inv-date-num.
  end.
end.
return "[!!Нет инвентаризаций по данному товару]" .
end function.

function gdsreffi_slt-pc returns decimal ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):
define variable v-host-code as integer no-undo .
define variable v-slt-pc as decimal no-undo .
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/pftxvalg.i buf_goods.gds-code {&slt-tax-code} ? v-host-code p-obj-type p-obj-code v-slt-pc no-error }
if not error-status:error then do:
  return v-slt-pc.
end.
else do:
  return ?.
end.
end function.

function gdsreffi_vat-pc returns decimal ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):

define variable v-host-code as integer no-undo .
define variable v-vat-pc as decimal no-undo .
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-host-code p-obj-type p-obj-code v-vat-pc no-error }
if not error-status:error then do:
  return v-vat-pc.
end.
else do:
  return ?.
end.
end function.

FUNCTION gdsreffi_last-pcnt returns decimal ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):
define buffer buf_gds-obj for ub.gds-obj.
define variable v-value as decimal no-undo .
find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_goods.gds-code
      AND  buf_gds-obj.obj-type = p-obj-type
      AND  buf_gds-obj.obj-code = p-obj-code no-error .
if available buf_gds-obj then do:
  assign
  v-value =
            (buf_gds-obj.price-sale / (if v-curr-r-b = {&r-b-base}
                                      then buf_gds-obj.last-base
                                      else buf_gds-obj.last-rubl)
              * 100 - 100)
  no-error
  .
end.
else do:
  v-value = ?  .
end.
return v-value.
end FUNCTION.
FUNCTION gdsreffi_in-doc-cli-name returns character ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_clients for ub.clients.
define buffer buf_parts for ub.parts.
define variable v-value as decimal no-undo .

for first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_goods.gds-code
      AND  buf_gds-obj.obj-type = p-obj-type
      AND  buf_gds-obj.obj-code = p-obj-code ,  
          first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_gds-obj.in-code,
          first buf_clients no-lock where buf_clients.obj-type = buf_trn-doc.cli-type and  buf_clients.obj-code = buf_trn-doc.cli-code:  
        return buf_clients.obj-name .      
end.
/* Если докуммента не нашли, а это может быть в случае обрезания, то берем из партии */
for first buf_parts no-lock where
           buf_parts.artic = buf_goods.artic
      and  buf_parts.prod-type = buf_goods.prod-type
      and  buf_parts.prod-code = buf_goods.prod-code
      AND  buf_parts.obj-type = p-obj-type
      AND  buf_parts.obj-code = p-obj-code
      and  buf_parts.out-code = {&free-code} ,  
          
          first buf_clients no-lock where buf_clients.obj-type = buf_parts.supp-type and  buf_clients.obj-code = buf_parts.supp-code:  
        return buf_clients.obj-name .      
end.
end FUNCTION.


PROCEDURE gds-ref-fi:
DEFINE PARAMETER BUFFER fi-goods for ub.goods.
DEFINE PARAMETER BUFFER fi-gds-obj for ub.gds-obj.
DEFINE INPUT PARAMETER v-obj-type like ub.clients.obj-type.
DEFINE INPUT PARAMETER v-obj-code like ub.clients.obj-code.
DEFINE INPUT PARAMETER v-gds-ref-fi as char no-undo.
define input parameter p-excel as logical no-undo .
DEFINE INPUT-OUTPUT PARAMETER fi-1 as char no-undo.
&if "{2}" = "gds-ref" &then
DEFINE INPUT-OUTPUT PARAMETER fi-2 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-3 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-4 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-5 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-6 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-7 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-8 as char no-undo.
&endif
DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE BUFFER fi-gds-prt for ub.gds-prt.
define buffer fi-condition-keeping for ub.condition-keeping .
&if "{2}" = "gds-ref" &then
DEFINE variable myfi as char no-undo extent 8.
&else
DEFINE variable myfi as char no-undo extent 1.
&endif
DEFINE VARiable jj as integer no-undo init 1.
DEFINE variable Myformat as character no-undo.
DEFINE VARiable vNum-entries as integer no-undo.
DEFINE VARiable entry-ii as character no-undo.
DEFINE VARiable vvalue as character no-undo.
DEFINE VARiable vtype as character no-undo.
DEFINE VARiable vlabel as character no-undo.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.

  IF v-gds-ref-fi = "" then
  v-gds-ref-fi = {&gdsreffi-ord}.
 if avail fi-goods then do:

&if "{1}" = "goo-doc" &then
&if "{3}" = "" &then
      FIND FIRST fi-gds-obj NO-LOCK where
                 fi-gds-obj.gds-code = fi-goods.gds-code AND
                 fi-gds-obj.obj-type = p-obj-type AND
                 fi-gds-obj.obj-code = p-obj-code NO-ERROR.
&else
      FIND FIRST fi-gds-obj NO-LOCK where
                 fi-gds-obj.gds-code = fi-goods.gds-code AND
                 fi-gds-obj.obj-type = {3} AND
                 fi-gds-obj.obj-code = {4} NO-ERROR.
&endif
&endif

vNum-entries = NUm-ENTRIES(v-gds-ref-fi).

&if "{2}" = "gds-ref" &then
&scop J-plus  jj = jj + 1.
&else
&scop J-plus
&endif
  DO ii = 1 to vNum-entries:

    entry-ii = ENTRY(ii, v-gds-ref-fi).
    find first buf_usr-flt_custom-labels where
              buf_usr-flt_custom-labels.tbl-name = entry(1, entry-ii, ".")
         and  buf_usr-flt_custom-labels.fld-name = entry(2, entry-ii, ".")
         and  buf_usr-flt_custom-labels.call-point =  {&uf-gdsreffi}  
         and  buf_usr-flt_custom-labels.call-type = {&add-fields} no-error.

    if  available buf_usr-flt_custom-labels then do:
      case buf_usr-flt_custom-labels.tbl-name:
        when {&table_goods} then do:
          if entry(2, entry-ii, ".") begins "#" then do:
            assign
            myfi[jj] =
            &if "{5}" <> "anyl-xls" &then
            buf_usr-flt_custom-labels.custom-label  + {&space-char} +
            &endif
                       string(dynamic-function(buf_usr-flt_custom-labels.custom-view-func, buffer fi-goods)
                              , buf_usr-flt_custom-labels.custom-format) no-error .
          end.
          else do:
            myfi[jj] =
            &if "{5}" <> "anyl-xls" &then
            buf_usr-flt_custom-labels.custom-label  + {&space-char} +
            &endif
                        string(buffer fi-goods:buffer-field(buf_usr-flt_custom-labels.fld-name):buffer-value, buf_usr-flt_custom-labels.custom-format).

          end.
        end.
        when {&table_gds-obj} then do:
          if entry(2, entry-ii, ".") begins "#" then do:
            assign
            myfi[jj] =
            &if "{5}" <> "anyl-xls" &then
            buf_usr-flt_custom-labels.custom-label  + {&space-char} +
            &endif
                       string(dynamic-function(buf_usr-flt_custom-labels.custom-view-func
                                      ,buffer fi-goods
                                      ,input v-obj-type  /*p-obj-type*/
                                      ,input v-obj-code /*p-obj-code*/
                                      )
                       , buf_usr-flt_custom-labels.custom-format) no-error .
          end.
          else do:
            if available fi-gds-obj then do:
              myfi[jj] =
              &if "{5}" <> "anyl-xls" &then
                          buf_usr-flt_custom-labels.custom-label  + {&space-char} +
              &endif
                          string(buffer fi-gds-obj:buffer-field(buf_usr-flt_custom-labels.fld-name):buffer-value, buf_usr-flt_custom-labels.custom-format).
            end.
            else do:
              myfi[jj] =
              &if "{5}" <> "anyl-xls" &then
              buf_usr-flt_custom-labels.custom-label +
              &Endif
              ""
              .
            end.
          end.
        end.
        when {&table_goods-attr} then do:
          if entry(2, entry-ii, ".") begins "#" then do:

          end.
          else do:
            vvalue = "[!!Ошибка]".
            run gds-attr-value in this-procedure ( fi-goods.gds-code
                                                  ,input entry(2, buf_usr-flt_custom-labels.fld-name, "_")
                                                  ,output vvalue
                                                  ,output vtype) no-error.
            myfi[jj] =
            &if "{5}" <> "anyl-xls" &then
            buf_usr-flt_custom-labels.custom-label  + {&space-char} +
            &Endif
                       native-string(vvalue, buf_usr-flt_custom-labels.fld-data-type, buf_usr-flt_custom-labels.custom-format).
          end.
        end.
        when {&table_gds-obj-attr} then do:
          if entry(2, entry-ii, ".") begins "#" then do:

          end.
          else do:
            vvalue = "[!!Ошибка]".
            run gdsoattr-value in this-procedure (
                                                  input  entry(2, buf_usr-flt_custom-labels.fld-name, "_")
                                                 ,input  fi-goods.gds-code
                                                 ,input v-obj-type  /*p-obj-type*/
                                                 ,input v-obj-code /*p-obj-code*/
                                                 ,output vvalue
                                                 ,output vtype
                                                 ) no-error .
            myfi[jj] =
            &if "{5}" <> "anyl-xls" &then
            buf_usr-flt_custom-labels.custom-label  + {&space-char} +
            &endif
                       native-string(vvalue, buf_usr-flt_custom-labels.fld-data-type, buf_usr-flt_custom-labels.custom-format).
          end.
        end.
        when {&table_gds-host-attr} then do:
          if entry(2, entry-ii, ".") begins "#" then do:

          end.
          else do:
            vvalue = "[!!Ошибка]".
            run gdshattr-value in this-procedure (
                                                  input  entry(2, buf_usr-flt_custom-labels.fld-name, "_")
                                                 ,input  fi-goods.gds-code
                                                 ,input v-obj-type  /*p-obj-type*/
                                                 ,input v-obj-code /*p-obj-code*/
                                                 ,output vvalue
                                                 ,output vtype
                                                 ) no-error .
            myfi[jj] =
            &if "{5}" <> "anyl-xls" &then
            buf_usr-flt_custom-labels.custom-label  + {&space-char} +
            &Endif
                       native-string(vvalue, buf_usr-flt_custom-labels.fld-data-type, buf_usr-flt_custom-labels.custom-format).
          end.
        end.
      end case.
      if p-excel then do:
        if buf_usr-flt_custom-labels.fld-data-type = {&abl-datatype-decimal}
        or buf_usr-flt_custom-labels.fld-data-type = {&abl-datatype-integer}
        then do:
          myfi[jj] = replace(myfi[jj], {&comma-char}, "").
        end.
      end.
      {&j-plus}
      if jj = 9 then LEAVE.
    end.
  
      else if entry(1, entry-ii, ".") = {&table_goods-attr} then  do: 
        vvalue = "[!!Ошибка]".
                run gds-attr-value in this-procedure ( fi-goods.gds-code
                                                      /* ,input entry(2, entry(2, entry-ii, "."), "_") */ 
                                                      ,input (SUBSTRING (entry-ii,INDEX(entry-ii,"_") + 1))
                                                      ,output vvalue
                                                      ,output vtype) no-error.
                                                      
                myfi[jj] = vvalue.
                /*
                &if "{5}" <> "anyl-xls" &then
                buf_usr-flt_custom-labels.custom-label  + {&space-char} +
                &Endif
                           native-string(vvalue, buf_usr-flt_custom-labels.fld-data-type, buf_usr-flt_custom-labels.custom-format).*/
      end.  
  END.  
  end.
  assign
  fi-1 = myfi[1]
&if "{2}" = "gds-ref" &then
  fi-2 = myfi[2]
  fi-3 = myfi[3]
  fi-4 = myfi[4]
  fi-5 = myfi[5]
  fi-6 = myfi[6]
  fi-7 = myfi[7]
  fi-8 = myfi[8]
&endif
  .

END PROCEDURE.

/* $Workfile$ e n d */