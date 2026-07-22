block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-pos.p $
$Archive: cus/ord-pos.p $

Вызов заказов поставщиков

Автор: Чернова Светлана Александровна
Дата создания: 08/21/01
Author: Svetlana Chernova
Creation date: 08/21/01

*/

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-place  as character no-undo .
define input parameter tt       as character no-undo .
define input parameter p-status as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-pos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-pos.p $":U .
define variable vss-description as character no-undo init "Вызов заказов".
{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }

define variable p-list        as character no-undo .
define variable g#type        as character no-undo .
define variable g#stat        as character no-undo .

define variable par-ord-ofof  as logical   no-undo .
define variable type-par      as character no-undo .

define variable v-obj-active  as character no-undo .
define variable v-office      as character no-undo .
define variable par-mode      as character no-undo .
define variable pardoc-rec    as recid no-undo .
define variable p-char        as character no-undo .


define variable list-mode   as character no-undo .
define variable store-type  as character no-undo .
define variable store-code  as integer   no-undo .
define variable g#host-name as character no-undo .
define variable g#host-code as integer   no-undo .


{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable v-fin-block as character no-undo .
if p-place = 'firm-fin':U    or
   p-place = 'without-fo':U  or
   p-place = 'with-fo':U
    then v-fin-block = ",fin-block" .
    else v-fin-block = "" .

define buffer buf_clients-name for ub.clients  .

if store-type = ? or store-type = "" then do:

  g#host-code = v-cntxt-host-code-obj .

  find first buf_clients-name no-lock where
             buf_clients-name.obj-code =  g#host-code and
             buf_clients-name.obj-type = {&cmp}
             no-error .
   g#host-name = buf_clients-name.obj-name.
   v-obj-active = 'no' .
end.
else do:
    { gbl/hostcode.i store-type store-code  g#host-code }

  find first buf_clients-name no-lock where
             buf_clients-name.obj-code =  g#host-code and
             buf_clients-name.obj-type = {&cmp}
             no-error .
   g#host-name = buf_clients-name.obj-name.

    { gbl/objat.i
    store-type
    store-code
      'active=request':u
      v-obj-active
    }
end.

/*
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
p-place
tt
p-status
.
*/

{ gbl/currdbat.i
  'office=request':u
  v-office
}

define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-ofof}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-ofof
  ,output type-par
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .

assign
    list-mode = p-place
    g#type = (If tt = "all":U     then ? else tt          )
    g#stat = (if p-status = "all":U then ? else p-status  )
    .

case g#type :
when {&o-o} then do:
   if g#type =  ? then  par-mode = {&obj}  .
                  else  par-mode =  "status":U .

    case g#stat :
        when {&g___new} then do:
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when {&ord-req} then do:
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when {&fact} then do:
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-lkp" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when ? then do:
          par-mode = {&obj}  .
          run cus/ord-ooz.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
    end case.
end.
when {&o-r} then do:
   if list-mode = "rc":U then do:
      if g#type =  ?
          then  par-mode = list-mode + {&obj}  .
          else  par-mode = list-mode + "status":U .
   end.
   else do:
      if g#type =  ?
          then  par-mode = {&obj}  .
          else  par-mode = "status":U .
   end.

    case g#stat :
        when {&g___new} then do:
          run cus/ord-orc.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when {&ord-req}  or
        when {&ord-per}  or
        when {&ord-rejection}  or
        when {&ord-ship}
          then do:
          run cus/ord-orc.w
            ( input   parParentProc,
              input  "b-lkp,b-close" ,
              input  par-mode    ,
              input  pardoc-rec  ,
              input  g#host-code ,
              input  store-code  ,
              input  store-type  ,
              input  g#type      ,
              input  g#stat      ,
              input  p-char      ,
              output p-list
              ).
        end.
        when {&fact} then do:
          run cus/ord-orc.w
          ( input   parParentProc,
            input  "b-lkp" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
        when ? then do:
            if list-mode = "rc":U then do:
                    par-mode = list-mode + {&obj}  .
            end.
            else do:
                    par-mode = {&obj}  .
            end.
          run cus/ord-orc.w
          ( input   parParentProc,
            input  "b-add,b-chg,b-del,b-lkp,b-close" ,
            input  par-mode    ,
            input  pardoc-rec  ,
            input  g#host-code ,
            input  store-code  ,
            input  store-type  ,
            input  g#type      ,
            input  g#stat      ,
            input  p-char      ,
            output p-list
            ).
        end.
    end case.

end.

otherwise do:
If g#stat    = {&g___new}
   or g#stat = {&ord-rejection}
   or g#type = {&o-f}
   then  do:
       if (list-mode = "obj" or list-mode = "firm" ) and g#type = ? then
          run ref/all-zakz.w
         ( input   parParentProc
          ,input   g#type
          ,input   g#stat
          ,input   list-mode
          ,input   ""
          ,input   "b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
          ,input   ""
          ,output  p-list       ) .
          else do:
              if  par-ord-ofof = false then dO :
                  If g#type = {&o-f} and g#db-num = 0 then do:
                      run ref/all-zakz.w
                      (   input   parParentProc
                         ,input   g#type
                         ,input   g#stat
                         ,input   list-mode
                         ,input   ""
                         ,input   "b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                         ,input   ""
                         ,output  p-list       ) .
                      end.
                      else do:
                      run ref/all-zakz.w
                      (      input   parParentProc
                            ,input   g#type
                            ,input   g#stat
                            ,input   list-mode
                            ,input   ""
                            ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                            ,input   ""
                            ,output  p-list       ) .
                      end.

              end.
              else do:
                  If g#type = {&o-f} and g#db-num = 0 then
                      run ref/all-zakz.w
                      (    input   parParentProc
                          ,input   g#type
                          ,input   g#stat
                          ,input   list-mode
                          ,input   ""
                          ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                          ,input   ""
                          ,output  p-list       ) .
                      else do:
                          If g#type = {&f-p} and g#db-num = 0 then
                                 run ref/all-zakz.w
                                 (   input   parParentProc
                                    ,input   g#type
                                    ,input   g#stat
                                    ,input   list-mode
                                    ,input   ""
                                    ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                                    ,input   ""
                                    ,output  p-list       ) .
                            else run ref/all-zakz.w
                                (   input   parParentProc
                                   ,input   g#type
                                   ,input   g#stat
                                   ,input   list-mode
                                   ,input   ""
                                   ,input   "b-chg,b-del,b-lkp,b-close,b-open" + v-fin-block
                                   ,input   ""
                                   ,output  p-list       ) .
                      end.
              end.
          end.
       end.
   else do:
      if v-fin-block = "" then
      run cus/zakz-rcv.w
      ( input   parParentProc
        ,input   g#type
        ,input   g#stat
        ,input   list-mode
        ,input   ""
        ,input   "b-add,b-chg,b-del,b-lkp,b-close,b-open"
        ,input   ""
        ,output  p-list       ) .
        else
           run ref/all-zakz.w
              ( input   parParentProc
                ,input   g#type
                ,input   g#stat
                ,input   list-mode
                ,input   ""
                ,input   "b-lkp" + v-fin-block
                ,input   ""
                ,output  p-list
                  ) .
    end.
end.
end case.
return.