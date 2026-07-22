block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-fpat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-fpat.p $":U .
define variable vss-description as character no-undo init "Размазывание по объектам используя атрибуты заказа".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable str-pos as integer no-undo .
define variable str-pos2 as integer no-undo .
define variable str-1 as character no-undo .
define variable i  as integer no-undo .
define variable e1 as character no-undo .
define variable e2 as integer no-undo .
define buffer buf_ord-doc       for ub.ord-doc  .
define buffer buf_ord-line      for ub.ord-line  .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
find first buf_ord-doc no-lock where
           buf_ord-doc.doc-code =  p-doc-code no-error .
if error-status :error then return error return-value .
define variable p-e-m as character no-undo .
p-e-m = buf_ord-doc.e-method.
for each  obj-list : delete obj-list . end.
    str-pos = index (  p-e-m , "&" ) .
    str-pos2 = length ( p-e-m ) - str-pos .
    str-1 = substring (p-e-m , str-pos + 1 , str-pos2 ).
    do i = 1 to num-entries (str-1) :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input e1 ,
   input e2 )
   .
    end.
define variable p-rcv-code as character no-undo .
define variable v-empty-rcv as logical no-undo .
do transaction :
  for each obj-list:
    run create-ord-doc-rcv in this-procedure
    (input obj-list.obj-type,
        input obj-list.obj-code ,
        output p-rcv-code ) .
        assign v-empty-rcv = yes.
        for each buf_ord-line no-lock where
                buf_ord-line.doc-code = buf_ord-doc.doc-code :
            find first buf_ord-line-attr no-lock where
                      buf_ord-line-attr.doc-code = buf_ord-doc.doc-code and
                      buf_ord-line-attr.gds-code = buf_ord-line.gds-code and
                      buf_ord-line-attr.attr-code = "objqnty"  + chr(4) +
                                                    obj-list.obj-type + chr(4) +
                                                    string(obj-list.obj-code)    no-error .
                if available buf_ord-line-attr and decimal (buf_ord-line-attr.attr-value) > 0 then do:
                  assign v-empty-rcv = no.
                  run create-ord-line-rcv in this-procedure
                      (input p-rcv-code ,
                       input decimal( buf_ord-line-attr.attr-value )).
                end.
        end.
        if v-empty-rcv = yes then do:
          find first ub.ord-doc-rcv where ub.ord-doc-rcv.rcv-code = p-rcv-code no-error.
          if available ub.ord-doc-rcv then do:
              delete ub.ord-doc-rcv.
          end.
        end.
  end.
end.
procedure create-ord-doc-rcv :
 do
 on error undo, return error return-value
 :
define input parameter  p-obj-type like ub.clients.obj-type no-undo .
define input parameter  p-obj-code like ub.clients.obj-code no-undo .
define output parameter loc-ord-num as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
loc-ord-num = "" .
find first  ub.ord-doc-rcv where
      ub.ord-doc-rcv.doc-code  = buf_ord-doc.doc-code and
      ub.ord-doc-rcv.obj-code  = p-obj-code and
      ub.ord-doc-rcv.obj-type  = p-obj-type no-lock no-error  .
if available ub.ord-doc-rcv  then do:
  loc-ord-num = ub.ord-doc-rcv.rcv-code .
  return.
end.
define variable store-type as character no-undo .
define variable store-code as integer   no-undo .
define variable v-i-doc as character no-undo .
store-type = p-obj-type.
store-code = p-obj-code.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   p-obj-type ,
  input   p-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
   create ub.ord-doc-rcv.
   buffer-copy buf_ord-doc to ub.ord-doc-rcv.
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-type  = 'out':U
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.creid     = v-cntxt-userid
      ub.ord-doc-rcv.status_   = 'новый':U
      ub.ord-doc-rcv.obj-code  = p-obj-code
      ub.ord-doc-rcv.obj-type  = p-obj-type
      ub.ord-doc-rcv.sub-par   = trim(entry(1, buf_ord-doc.cli-out-doc, chr(4))) + chr(4) + trim(buf_ord-doc.vat-type) + chr(4)
   .
  end.
end procedure.
procedure create-ord-line-rcv :
 do
 on error undo, return error return-value
 :
 define input parameter p-rcv-code as character no-undo .
 define input parameter p-qnty     as decimal   no-undo .
 define buffer b-ord-doc-rcv  for ub.ord-doc-rcv.
 create ub.ord-line-rcv .
 BUFFER-COPY buf_ord-line to ub.ord-line-rcv
 assign
   ub.ord-line-rcv.rcv-code  = p-rcv-code
   ub.ord-line-rcv.qnty      = p-qnty
 .
    find first ub.goods no-lock where
               ub.goods.gds-code = buf_ord-line.gds-code .
    if can-find ( first ub.units where ub.units.unit-name = ub.goods.unit-base
        and lookup('шту':U, ub.units.type) > 0)
        and trunc( ub.ord-line-rcv.qnty, 0 ) <> ub.ord-line-rcv.qnty then do:
            ub.ord-line-rcv.qnty = trunc( ub.ord-line-rcv.qnty, 0 ) + 1 .
    end.
    ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate .
    if can-find(first ub.units where ub.units.unit-name = ub.goods.unit-cli
        and lookup('шту':U, ub.units.type) > 0)
        and trunc( ub.ord-line-rcv.cli-qnty, 0 ) <> ub.ord-line-rcv.cli-qnty then do:
            ub.ord-line-rcv.cli-qnty = trunc( ub.ord-line-rcv.cli-qnty, 0 ) + 1 .
            ub.ord-line-rcv.qnty  = ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.cli-base-rate .
    end.
 end.
end procedure.
