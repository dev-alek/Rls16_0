block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

{ cmp/str-glbl.i}

{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }

define buffer cli_shops for ub.clients .

for each cli_shops no-lock where
             cli_shops.obj-type = {&shop} and
             cli_shops.db-num = v-cntxt-db-num
:             
   run str/diallog.w (
           input parparentproc
         , input this-procedure
         , input "str/send-all.p":U
         , input ( cli_shops.obj-type + {&delim-par} + string(cli_shops.obj-code) + {&delim-par} + 'D':U + {&delim-par} + 'emrcdel':U + {&delim-par} + 'Удаление справочника ЕМЦ':U)
         , input yes /*p-auto-go*/
         , input "":U
         , input substitute("Отсылка очистки справочника ЕМЦ")
     ) no-error.
   
   
    run str/diallog.w (
           input parparentproc
         , input this-procedure
         , input "str/send-all.p":U
         , input ( cli_shops.obj-type + {&delim-par} + string(cli_shops.obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'emrc':U + {&delim-par} + 'Передача справочника ЕМЦ':U)
         , input yes /*p-auto-go*/
         , input "":U
         , input substitute("Отсылка справочника ЕМЦ")
     ) no-error.
end.
oOk = true.