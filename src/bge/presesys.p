block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: presesys.p $
$Archive: bge/presesys.p $

Создание списка выгруженных и работающих ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

define output parameter p-pres-esys-list as character no-undo .
define output parameter p-message      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: presesys.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/presesys.p $":U .
define variable vss-description as character no-undo init "Создание списка выгруженных и работающих ВС ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

do
on error undo, return error
:
  define buffer buf_ext-system for ub.ext-system.

  define variable v-unpres-esys-list as character no-undo .
  define variable v-unpres-esys-list-view as character no-undo .

  assign
    p-pres-esys-list   = "":U
    p-message        = "":U
    v-unpres-esys-list = "":U
  .

  for each buf_ext-system no-lock where
  buf_ext-system.esys-db-num-exp = g#db-num
  or buf_ext-system.esys-db-num-imp = g#db-num
  on error undo, return error
  :
    if buf_ext-system.esys-status = 1
    then do:
      if p-pres-esys-list = "":U then do:
        assign
          p-pres-esys-list =
          substitute("&1&2&3"
                                      , buf_ext-system.esys-id
                                      , {&delim-par}
                                      , buf_Ext-system.db-num )
        .
      end.
      else do:
        assign
          p-pres-esys-list = p-pres-esys-list + ",":U +
                            substitute("&1&2&3"
                                      , buf_ext-system.esys-id
                                      , {&delim-par}
                                      , buf_Ext-system.db-num )

        .
      end.
    end.
    else do:
      if v-unpres-esys-list = "":U then do:
        assign
          v-unpres-esys-list =  string(buf_Ext-system.esys-id )

        .
      end.
      else do:
        assign
          v-unpres-esys-list = v-unpres-esys-list + ",":U + string(buf_Ext-system.esys-id )
        .
      end.
    end.
  end.
  if v-unpres-esys-list <> "":U then do:
    assign
      p-message = substitute( "Работа Системы OXML с ВС &1 не производится", v-unpres-esys-list )
    .
  end.
end.

/* $Workfile: presesys.p $ end */