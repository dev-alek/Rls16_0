block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 17 февр. 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 17 февр. 2021 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Подтверждение команды".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ adm/auto-def.i new}
log-file-name = "commandcomite.txt".
define variable v-answer-code as integer   no-undo.
define variable v-answer-msg  as character no-undo.
define variable v-command     as character no-undo.
define input  parameter iDb-num as integer no-undo.
define buffer db-rec-attr for ub.db-rec-attr.
for each db-rec-attr where ( db-rec-attr.db-num             eq iDb-num  /* если база наша и у нас не выполнена команда */
                       and   db-rec-attr.attr-value-logical ne true ) 
                            or iDb-num eq 0 /* выполнить команды по отключенным */
no-lock :
   if    db-rec-attr.attr-type = "execution":U
      or db-rec-attr.attr-type = "recover":U
   then do:
      assign
         v-answer-code = 0
         v-answer-msg  = ""
      .
   end.
   else do:
      assign
         v-answer-code = 0
         v-answer-msg  = ""
      .
   end.
   assign
      v-command = "command":U                                                 + {&delim-nws}
                + "two-commit":U                                              + {&delim-nws}
                + db-rec-attr.attr-code /* p1-action */                       + {&delim-nws}
                + db-rec-attr.attr-type /* p1-operation */                    + {&delim-nws}
                + db-rec-attr.uniq-key-rec /* p1-uniq-key-rec */              + {&delim-nws}
                + string( db-rec-attr.attr-value-decimal /* p1-db-init */ )   + {&delim-nws}
                + db-rec-attr.attr-value /* p1-parameters */                  + {&delim-nws}
                + string( v-answer-code )                                     + {&delim-nws}
                + v-answer-msg
     .
   run nws/dbreccmd.p ( input db-rec-attr.db-num
                       ,input v-command
            ) no-error .
   if error-status :error
   then do:
      run write-to-log( substitute( "&1 (two-commit). &2&3&4 переходим к следующей операции", vss-workfile, return-value, {&new-line}, error-status:get-message( 1 ) ) ).
/*      return error. с этой операцией не удалось пойдем к следующей*/
   end.                                
end.
