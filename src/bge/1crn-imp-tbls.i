
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Импорт в 1С (временные таблицы)

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".



define temp-table tt-gds-grp no-undo
  field code_ as character
  field del-l as integer
  field del-f as integer
  field upper-code as character
  field name_ as character
  index pi is primary code_
.

define temp-table tt-goods no-undo
  field code_         as character
  field del-l         as integer
  field del-f         as integer
  field grp-code      as character
  field name          as character
  field label-name    as character
  field chk-name      as character
  field artic         as character
  field unit-code     as character
  field prod-code     as character
  field wt            as decimal
  field ms            as decimal
  field gds-type      as character
  field img           as character
  field unit-spl-code as character
  field unit-k        as decimal
  field nds-code      as decimal
  field enbl-ne       as integer
  field enbl-zc       as integer
  field srvc-type     as integer
  index pi is primary code_
  .

  
define temp-table tt-obj no-undo
  field code_    as character
  field del-l    as integer
  field del-f    as integer
  field name     as character
  field frm-code as character
  field grp-code as character
  field address  as character
  field tel      as character
  field director as character
  field accr     as character
  index pi is primary code_
  .

define temp-table tt-tanks no-undo
  field tank-code as character
  field del-l     as integer
  field del-f     as integer
  field name_     as character
  field gs-code   as character
  index pi is primary tank-code
  .

define temp-table tt-cli-grp no-undo
  field code_  as character
  field upper-code  as character
  field del-l as integer
  field del-f as integer
  field name_  as character
  index pi is primary code_
  .

define temp-table tt-clients no-undo
  field code_     as character
  field del-l     as integer
  field del-f     as integer
  field name_     as character
  field full-name as character
  field grp-code  as character
  field city      as character
  field ind       as character
  field inn       as character
  field kpp       as character
  field agnt      as character
  field post-adr  as character
  field e-mail    as character
  field leg-adr   as character
  field okpo      as character

  index pi is primary code_
  .

define temp-table tt-contracts no-undo
  field code_      as character
  field del-l     as integer
  field del-f     as integer
  field org-code  as character
  field cont-code as character
  field date-srt  as date
  field date-end  as date
  index pi is primary code_
  .
  
define temp-table tt-bank-acc no-undo
  field r-schet   as character
  field del-l     as integer
  field del-f     as integer
  field cont-code as character
  field bank-name as character
  field bik       as character
  field bank-city as character
  field cor-acc   as character
  index pi is primary r-schet
  .
  
define temp-table tt-units no-undo
  field okei-code as character
  field del-l     as integer
  field del-f     as integer
  field name      as character
  field full-name as character
  index pi is primary okei-code
  .
  
define temp-table tt-firms no-undo
  field code_  as character
  field del-l as integer
  field del-f as integer
  field name  as character
  index pi is primary code_
  .
  
define temp-table tt-prs no-undo
  field code_  as character
  field del-l as integer
  field del-f as integer
  field name  as character
  field role-code as integer
  index pi is primary code_
  .

define temp-table tt-currencies no-undo
  field code_    as character
  field del-l    as integer
  field del-f    as integer
  field name     as character
  field sym-name as character
  index pi is primary code_
  .
    
define temp-table tt-countries no-undo
  field code_      as character
  field del-l     as integer
  field del-f     as integer
  field name_      as character
  field full-name as character
  field alfa2     as character
  field alfa3     as character
  index pi is primary code_
  .
  
define temp-table tt-business-unit no-undo
  field code_ as character
  field del-l as integer
  field del-f as integer
  field name_ as character

  index pi is primary code_
  .
  
define temp-table tt- no-undo

  index pi is primary code_
  .
  
define temp-table tt- no-undo

  index pi is primary code_
  .
  
define temp-table tt- no-undo

  index pi is primary code_
  .
    
