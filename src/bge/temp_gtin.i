
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблицы с GTIN

Автор: Шкляр Елена  
Дата создания: 10/10/08
Author: Shklyar Elena
Creation date: 10/10/08
*/


/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */
 
/* ***************************  Main Block  *************************** */

DEFINE TEMP-TABLE tt-goods NO-UNDO LIKE bar-code
   field gds-name  as character
   field barcode   as character
   field GTIN      as character
   field qnty      as integer
   field type-mark as character
   index pi as UNIQUE gds-code barcode GTIN.