 define input  parameter pid as int64 no-undo.
{ref/brwhist.i &buf_obj-hist = c-operserv }  

function get-subject returns character
  ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-obj-hist-code p-subject
  return p-subject.   /* Function return value. */

end function.
 
procedure local-view-cange:
   define output parameter odescription as character no-undo.
   run Operserv-proc (output odescription).
   
         
end procedure.
  
function local-open-br returns logical 
(  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character ):
     define variable sort-column-phrase as character no-undo .
     define variable l-query-was-opened as logical no-undo .
     if p-mode eq "one"
     then do:
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-obj-hist.id         = pid  "
          &dyn_where-cond = " substitute('  X_c-obj-hist.id  = &1 ', pid)  "

          &use-ind    = " "
          &by         = "  " }
     end.
     else do:
     
{ gbl/fltopend.i
          &where-cond = " TRUE "
          
          &by         = "  " }
     end.
  return true.
end.

procedure operserv-proc :
define output parameter p-description as character no-undo .

define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  
&scop fields-name-list "OSname,OsNameAbbr,QuantMin,QuantMax,SummMin,SummMax,SummAtent,CommType,CommSumm,CommPerc,PreAAvt,PreSlip,SlipName,CalcType,ext-code,OsType,OperAddr,OperInn,OperName,AgentTel,OperTel,AgentFlagRasch,InnSupp,OperTelTran,AgentOpere,SuppTel,~
SuppName,Status_,AgentFlag"

define variable v-label-param as character no-undo .
  v-label-param =
   "OSname"          + {&delim-par} + "Наименование оператора"                + {&delim-par} + "" + {&delim-flf}
 + "OsNameAbbr"      + {&delim-par} + "Аббр. оператора"                       + {&delim-par} + "" + {&delim-flf}
 + "QuantMin"        + {&delim-par} + "Мин.кол.цифр"                          + {&delim-par} + "" + {&delim-flf}
 + "QuantMax"        + {&delim-par} + "Макс.кол.цифр"                         + {&delim-par} + "" + {&delim-flf}
 + "SummMin"         + {&delim-par} + "Мин.сумма"                             + {&delim-par} + "" + {&delim-flf}
 + "SummMax"         + {&delim-par} + "Макс.сумма"                            + {&delim-par} + "" + {&delim-flf}
 + "SummAtent"       + {&delim-par} + "Порог сумм.для предупр."               + {&delim-par} + "" + {&delim-flf}
 + "CommType"        + {&delim-par} + "Тип ввода комиссии"                    + {&delim-par} + "" + {&delim-flf}
 + "CommSumm"        + {&delim-par} + "Сумма комиссии"                        + {&delim-par} + "" + {&delim-flf}
 + "CommPerc"        + {&delim-par} + "Процент комиссии"                      + {&delim-par} + "" + {&delim-flf}
 + "PreAAvt"         + {&delim-par} + "Необх.автор."                          + {&delim-par} + "" + {&delim-flf}
 + "PreSlip"         + {&delim-par} + "Необх. Печ. слипа"                     + {&delim-par} + "" + {&delim-flf}
 + "SlipName"        + {&delim-par} + "Имя файла конеч.слипа"                 + {&delim-par} + "" + {&delim-flf}
 + "CalcType"        + {&delim-par} + "Тип расчета с опер.пополн."            + {&delim-par} + "" + {&delim-flf}
 + "ext-code"        + {&delim-par} + "ext-code"                              + {&delim-par} + "" + {&delim-flf}
 + "OsType"          + {&delim-par} + "Тип"                                   + {&delim-par} + "" + {&delim-flf}
 + "OperAddr"        + {&delim-par} + "Адрес оператора перевода"              + {&delim-par} + "" + {&delim-flf}
 + "OperInn"         + {&delim-par} + "ИНН оператора перевода"                + {&delim-par} + "" + {&delim-flf}
 + "OperName"        + {&delim-par} + "Наименование оператора перевода"       + {&delim-par} + "" + {&delim-flf}
 + "AgentTel"        + {&delim-par} + "Телефон платежного агента"             + {&delim-par} + "" + {&delim-flf}
 + "OperTel"         + {&delim-par} + "Телефон оператора по приему платежей"  + {&delim-par} + "" + {&delim-flf}
 + "AgentFlagRasch"  + {&delim-par} + "Признак агента по предмету расчета"    + {&delim-par} + "" + {&delim-flf}
 + "InnSupp"         + {&delim-par} + "ИНН поставщика"                        + {&delim-par} + "" + {&delim-flf}
 + "OperTelTran"     + {&delim-par} + "Телефон оператора перевода"            + {&delim-par} + "" + {&delim-flf}
 + "AgentOpere"      + {&delim-par} + "Операция платежного агента"            + {&delim-par} + "" + {&delim-flf}
 + "SuppTel"         + {&delim-par} + "Телефон поставщика"                    + {&delim-par} + "" + {&delim-flf}
 + "SuppName"        + {&delim-par} + "Наименование поставщика"               + {&delim-par} + "" + {&delim-flf}
 + "Status_"         + {&delim-par} + "Статус"                                + {&delim-par} + "" + {&delim-flf}
 + "AgentFlag"       + {&delim-par} + "Признак агента"                        + {&delim-par} + "" .

  run proc-full-temp-changes in this-procedure (
                                               input X_c-obj-hist.action = integer({&hn-create})
                                              ,input X_c-obj-hist.action = integer({&hn-delete})
                                              ,input  buffer X_c-obj-hist:handle
                                              ,input  {&table_operserv}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* cashbook-proc */

