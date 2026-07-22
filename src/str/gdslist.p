/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка товаров

Автор: Шкляр Елена
Дата создания: 04/10/06
Author: Shklyar Elena
Creation date: 04/10/06


  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
  
define input parameter parparentproc as handle no-undo.
define output parameter gdslist as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирование списка товаров".

  { cmp/str-glbl.i }
  { cmp/library.i  }
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }
  { cmp/gds-list.i gds-list def "new shared"}
do:
    
    run str/gds-list.w ( input parparentproc
      , input v-cntxt-host-code-obj
      , input v-cntxt-obj-type
      , input v-cntxt-obj-code).
      
    for each gds-list:
      gdslist = gdslist + {&delim-cmd} + string(gds-list.gds-code) .
    end.  
    
    gdslist = trim (gdslist) .
      
                      
end.

