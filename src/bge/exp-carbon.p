block-level on error undo, throw.
/*

$Revision: 5e6d336d3afb, 114, rls $
$Author: EShklyar $
$Date: Tue Dec 23 19:14:55 2014 +0300 $
$Workfile: exp-carbon.p $
$Archive: bge/exp-carbon.p $

Процедура выгрузки данных в Carbon

Автор: Гридчина Полина Дмитриевна
Дата создания: 14/08/25
Author: Gridchina Polina
Creation date: 14/08/25

*/

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 23 19:14:55 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-carbon.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/exp-carbon.p $":U .
define variable vss-description as character no-undo init "Процедура выгрузки данных в Carbon".

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Includes  ************************** */

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/lib-trn.i  }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ ref/gds-attr.i }

/* ***************************  Definitions  ************************** */

/* Input parameters */
DEFINE INPUT PARAMETER p-log-handle AS HANDLE NO-UNDO. /* handle по которому находится процедура записи лога */
DEFINE INPUT PARAMETER p-company AS char NO-UNDO. /*Код компании в Карбон. Это основной код для всей компании*/
DEFINE INPUT PARAMETER p-directory AS CHARACTER NO-UNDO. /* Папка для выгрузки */
DEFINE INPUT PARAMETER p-prefix AS char NO-UNDO. /* Префикс для выгрузки справочника товарных групп и товаров */
DEFINE INPUT PARAMETER p-grp-fuel AS char NO-UNDO. /* Код группы для топлива */
DEFINE INPUT PARAMETER p-grp-spec AS char NO-UNDO. /* Код группы для специализированных товаров, запрещенных к начислению бонусов */


DEFINE VARIABLE v-logname AS CHARACTER NO-UNDO. 
DEFINE VARIABLE file_name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-date-file AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-numfile AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE v-num-SHC AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE v-num-SHE AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE v-num-SG  AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE v-num-SHM AS INTEGER INITIAL 0 NO-UNDO.
define variable v-attr-value    as character no-undo .
define variable v-attr-type     as character no-undo .
def var v-name as char no-undo.

DEFINE VARIABLE v-delim AS CHARACTER NO-UNDO init ';'.
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.

DEFINE BUFFER buf_gds-grp FOR gds-grp.
DEFINE BUFFER buf_goods FOR goods.


v-logname = p-directory + "exp-carbon.txt":U.
/* p-prefix = p-prefix + '_':U. */
/* Для лога 
&scop display-message run write-log-and-file in p-log-handle ~
    (input 1, input c-logname, input 1, input ~{&my-message~})

&scop my-message substitute("Начало выгрузки данных в Carbon")
{&display-message}.
*/

v-date-file  = STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + substring(string(time,"HH:MM"),1,2) + substring(string(time,"HH:MM"),4,2).
file_name = p-directory + 'TK_':U + v-date-file  + '.csv'.
OUTPUT TO VALUE(file_name).

/* Получим из атрибута номер последнего выгруженного пакета */

    FIND FIRST db-attr WHERE db-attr.db-num = g#db-num AND db-attr.attr-code = 'Carbon-fileId':U NO-ERROR.
    IF AVAILABLE db-attr THEN DO:        
            v-numfile = INTEGER(db-attr.attr-value) + 1.        
    END.
    ELSE DO:
        CREATE db-attr.
        ASSIGN
            db-attr.db-num = g#db-num
            db-attr.attr-code = 'Carbon-fileId':U
            db-attr.attr-value =  "1"
            v-numfile = 0.
    END.
  /* Пишем заголовок файла */
  put unformatted  substitute("H&1&2&1&3&1&4&1INC&10",v-delim,'CTL_TNKBP_FED',v-numfile,v-date-file) skip.
  
  /* Выгружаем товарные группы */
  /* Головная запись товарного классификатора региона. Вся заполняется префиксом */
  Put unformatted substitute("SHC&1&2&1&2&1&2",v-delim,p-prefix) skip.
  v-num-SHC = v-num-SHC + 1.
  /* Создаем 2 специальные группы для топлива и для спец. товаров, на которые не начисляются бонусы */
  Put unformatted substitute ("SHE&1&2&1&2_&3&1Топливо",v-delim,p-prefix,p-grp-fuel) skip.
  v-num-SHE = v-num-SHE + 1.
  Put unformatted substitute ("SHE&1&2&1&2_&3&1Спец. группа",v-delim,p-prefix,p-grp-spec) skip.
  v-num-SHE = v-num-SHE + 1.
  
  /* Сами группы */
  run put-grp(1).
  /*
  for each buf_gds-grp where buf_gds-grp.node-code > 1 no-lock by buf_gds-grp.lvl-num :
      Put unformatted substitute ("SHE&1&2&1&2_&3&1&5&4",v-delim,p-prefix,buf_gds-grp.node-code,if buf_gds-grp.upper-code > 1 then ';' + p-prefix + '_' + string(buf_gds-grp.upper-code) else '',buf_gds-grp.node-name) skip.
      v-num-SHE = v-num-SHE + 1.      
  end.
*/
  If index(v-name,';') > 0 then v-name = '"' + v-name + '"'.
  /* Выгружаем товары. Если топливо, то в топливную группу, если спец. то в спец. */
  for each buf_goods where stts = 0 no-lock:
      v-name = replace(buf_goods.gds-name,'"',"'").
      Put unformatted substitute ("SG&1&2_&3&1&4",v-delim,p-prefix,buf_goods.gds-code,v-name) skip.
      v-num-SG = v-num-SG + 1.
      { str/is-petrl.i
                    buf_goods.artic
                    buf_goods.prod-type
                    buf_goods.prod-code
                    v-is-petrol
                    v-is-pieces
      }
       run gds-attr-value in this-procedure
        ( input  buf_goods.gds-code
        , input  {&attr-ban-bonus}
        , output v-attr-value
        , output v-attr-type
        ) .
      if lookup(v-attr-value, 'true,yes':u) > 0 then do:   /*  Товар без бонусов */
       Put unformatted substitute ("SHM&1&2_&3&1&2&1&2_&4",v-delim,p-prefix,buf_goods.gds-code,p-grp-spec) skip.    
      end. 
      else if v-is-petrol then do:
          Put unformatted substitute ("SHM&1&2_&3&1&2&1&2_&4",v-delim,p-prefix,buf_goods.gds-code,p-grp-fuel) skip.          
      end.    
      else Put unformatted substitute ("SHM&1&2_&3&1&2&1&2_&4",v-delim,p-prefix,buf_goods.gds-code,buf_goods.grp-code) skip.
      v-num-SHM = v-num-SHM + 1.
  end.
    /* Контрольная запись */
  put unformatted  substitute("T&10&10&1&2&10&10&10&1&3&10&1&4&10&10&10&1&5&10&10",v-delim,v-num-SHC,v-num-SHE,v-num-SG,v-num-SHM) skip.
  output close.
  /* Проставили номер пакета */
  db-attr.attr-value = string(v-numfile).
  
  /*    run gds-attr-value in this-procedure
        ( input  buf_tt-place.gds-code
        , input  {&attr-ptrl-without-rvs}
        , output v-attr-value
        , output v-attr-type
        ) .
    if lookup(v-attr-value, 'true,yes':u) > 0
  */

  procedure put-grp :
    define input parameter p-upper   as integer          no-undo.
    for each buf_gds-grp where  buf_gds-grp.upper-code = p-upper   no-lock :
      Put unformatted substitute ("SHE&1&2&1&2_&3&1&5&4",v-delim,p-prefix,buf_gds-grp.node-code,if buf_gds-grp.upper-code > 1 then ';' + p-prefix + '_' + string(buf_gds-grp.upper-code) else '',buf_gds-grp.node-name) skip.
      v-num-SHE = v-num-SHE + 1.      
      run put-grp(buf_gds-grp.node-code).
    end.
  end procedure.
