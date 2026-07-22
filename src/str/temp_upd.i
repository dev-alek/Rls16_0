
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблицы с УПД

Автор: Шкляр Елена  
Дата создания: 10/10/08
Author: Shklyar Elena
Creation date: 10/10/08
*/


/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */
 
/* ***************************  Main Block  *************************** */



define temp-table tt-utd like ub.utd 
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .

define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id 
  .
  
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer 
    field doc-id  as integer 
    field linenum as integer 
    field bar-code as character 
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.

define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal 
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical /* весовой товар */
  field isVarWeight as logical /* товар с переменным весом */
  field isSelect    as logical
  field markType    as character /* тип маркировки */
  field PieceTTH    as character
  field PieceFact   as character  
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
  
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
      
define temp-table tt-mark-line like ub.marking-lines 
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
  
define temp-table tt-marking like ub.marking 
  .
  
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .    
  
define temp-table tt-inv-marking no-undo 
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .  
  
define temp-table tt-tech-mark no-undo 
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .  
  
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .  