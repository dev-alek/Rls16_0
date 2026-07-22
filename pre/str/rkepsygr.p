block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-rid-list as character no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkepsygr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsygr.p $":U .
define variable vss-description as character no-undo init "Синхронизация групп блюд для товаров в IBS TH с товарами на кассе R-keeper".
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
define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-rid as recid no-undo .
define variable v-stop-state as logical no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ii0 AS INTEGER NO-UNDO.
define variable ii-ok as integer no-undo .
DEFINE BUFFER buf_cd-plu FOR ub.cd-plu .
define buffer buf_cd-doc-line for ub.cd-doc-line.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref2 as character no-undo .
define variable varpgscales-pref2 as character no-undo .
define variable varscales-pref-type2 as character no-undo.
define variable varpgscales-pref-type2 as character no-undo.
varscales-pref2  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref2
  ,output varscales-pref-type2
  ) no-error .
  if varscales-pref2 = ? then do:
    assign
      varscales-pref2 = '21,23,25':U.
  end.
varpgscales-pref2  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref2
  ,output varpgscales-pref-type2
  ) no-error .
  if varpgscales-pref2 = ? then do:
    assign
      varpgscales-pref2 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
  end.
function get-rkgTH-price returns decimal(input p-obj-type as character
                                       , input p-obj-code as integer
                                       , input p-b-code as integer
                                       , output p-doc-num as character):
define variable v-price-sale as decimal   no-undo init ?.
define variable v-road-tax   as decimal   no-undo .
define variable v-excise     as decimal   no-undo .
define variable v-vat-pc     as decimal   no-undo .
define variable v-slt-pc     as decimal   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output p-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ,output v-vat-pc
  ,output v-slt-pc
  ) no-error .
if not error-status:error then return v-price-sale.
END FUNCTION.
function get-rkgTH-name returns character(input p-obj-type as character
                                          ,input p-obj-code as integer
                                          ,input p-b-code as integer
                                          , buffer buf_goods for ub.goods):
define variable v-gds-name as character no-undo .
define VARIABLE varresult   as character                no-undo.
define VARIABLE vartype-bc  as character                no-undo.
define VARIABLE varweight   as decimal                  no-undo.
DEFINE VARIABLE v-unit-cli AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-f-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_bar-code FOR ub.bar-code.
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
DEFINE BUFFER buf_place FOR ub.place.
DEFINE BUFFER buf_gds-prt FOR ub.gds-prt.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  STRING(p-b-code)
,input  0
,input  p-obj-type
,input  p-obj-code
,input  NO
,input  YES
,input  varscales-pref2
,input  varpgscales-pref2
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
if not available buf_bar-code then
return "!!!НЕИЗВЕСТНЫЙ ТОВАР".
FIND FIRST buf_goods NO-LOCK WHERE
          buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.
IF NOT AVAILABLE buf_goods THEN DO:
  return "!!!НЕИЗВЕСТНЫЙ ТОВАР".
END.
else do:
  assign
  v-gds-name = buf_goods.chk-name
  .
end.
IF buf_bar-code.unit-cli <> buf_goods.unit-base THEN DO:
  ASSIGN
  v-unit-cli = "*" + string(buf_bar-code.cli-base-rate).
END.
FIND FIRST buf_gds-prt NO-LOCK WHERE
          buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
if buf_gds-prt.node-name <>  '_Пустая шкала':U THEN DO:
    FIND FIRST buf_gds-prt NO-LOCK WHERE
              buf_gds-prt.node-code = buf_bar-code.node-code NO-ERROR.
END.
ASSIGN
v-f-name = (IF AVAILABLE buf_gds-prt THEN buf_gds-prt.f-name ELSE "":U).
ASSIGN
v-gds-name = v-gds-name + chr(32) + v-f-name + v-unit-cli.
return v-gds-name.
END FUNCTION.
function get-rkgTH-group returns integer(input p-obj-type as character
                                        , input p-obj-code  as integer
                                        , input p-gds-code as integer
                                        , output p-grp-name as character
                                        ):
DEFINE BUFFER buf_fbr-gds-obj FOR ub.fbr-gds-obj.
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
FIND FIRST buf_fbr-gds-obj NO-LOCK WHERE
        buf_fbr-gds-obj.obj-type = p-obj-type
    AND buf_fbr-gds-obj.obj-code = p-obj-code
    AND buf_fbr-gds-obj.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_fbr-gds-obj THEN DO:
  RUN fbrglib-get-full-name IN THIS-PROCEDURE(
                                              input p-obj-type
                                              ,INPUT p-obj-code
                                              ,INPUT buf_fbr-gds-obj.fbr-grp-code
                                              ,OUTPUT p-grp-name) NO-ERROR.
  return buf_fbr-gds-obj.fbr-grp-code.
END.
return ?.
END FUNCTION.
function get-rkgTH-modificator returns logical(input p-obj-type as character
                                        , input p-obj-code  as integer
                                        , input p-gds-code as integer
                                        , output p-is-null-price as logical
                                        ):
DEFINE BUFFER buf_fbr-gds-obj FOR ub.fbr-gds-obj.
FIND FIRST buf_fbr-gds-obj NO-LOCK WHERE
        buf_fbr-gds-obj.obj-type = p-obj-type
    AND buf_fbr-gds-obj.obj-code = p-obj-code
    AND buf_fbr-gds-obj.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_fbr-gds-obj THEN DO:
  assign
  p-is-null-price = buf_fbr-gds-obj.is-null-price
  .
  return buf_fbr-gds-obj.is-modificator.
END.
assign
p-is-null-price = no.
return no.
END FUNCTION.
function get-rkgTH-group-name returns character(input p-obj-type as character
                                              , input p-obj-code  as integer
                                              , input p-out-code as integer):
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
          buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
      and buf_fbr-gds-grp.out-code = p-out-code no-error .
if not available buf_fbr-gds-grp then return ?.
return buf_fbr-gds-grp.node-name.
END FUNCTION.
function get-rkgTH-parent returns integer(input p-obj-type as character
                                          , input p-obj-code  as integer
                                          , input p-out-code as integer):
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
DEFINE BUFFER upper_fbr-gds-grp FOR ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
          buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
      and buf_fbr-gds-grp.out-code = p-out-code no-error .
if not available buf_fbr-gds-grp then return ?.
find first upper_fbr-gds-grp no-lock where
          upper_fbr-gds-grp.obj-type = p-obj-type
      AND upper_fbr-gds-grp.obj-code = p-obj-code
      and upper_fbr-gds-grp.out-code = buf_fbr-gds-grp.upper-code no-error .
if not available upper_fbr-gds-grp then return ?.
return upper_fbr-gds-grp.out-code.
END FUNCTION.
procedure get-rkep-full-grp-name :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER p-grp-code LIKE ub.cd-grp.grp-code NO-UNDO.
define output parameter p-full-name as character    no-undo.
define variable v-upper-code    as integer  no-undo.
define buffer buf_cd-grp       for ub.cd-grp.
define buffer buf_upper_cd-grp for ub.cd-grp.
do
on error undo, return error
:
    if P-grp-code = 0
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_cd-grp no-lock where
               buf_cd-grp.obj-type = 'маг':U
           and buf_cd-grp.obj-code = p-obj-code
           and buf_cd-grp.pos-type = 'r-keeper':U
           and buf_cd-grp.grp-type = '':U
           and buf_cd-grp.grp-code = p-grp-code
        no-error.
        if not available buf_cd-grp
        then do:
            undo, return error substitute("get-rkep-grp-name: Не найдена группа меню на кассе R-KEEPER с кодом &1", p-grp-code).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 0
        .
        do while true
        on error undo, return error "get-rkep-grp-name: Ошибка составления полного имени группы"
        :
            assign
            p-full-name  = buf_cd-grp.grp-name
                        + (if p-full-name <> "" then chr(47) else "")
                        + p-full-name
            v-upper-code = buf_cd-grp.upper-grp-code
            .
            if buf_cd-grp.grp-code = 0
            then do:
                leave.
            end.
            find first buf_cd-grp no-lock where
                      buf_cd-grp.obj-type = 'маг':U
                  and buf_cd-grp.obj-code = p-obj-code
                  and buf_cd-grp.pos-type = 'r-keeper':U
                  and buf_cd-grp.grp-type = '':U
                  and buf_cd-grp.grp-code = v-upper-code no-error.
            if not available buf_cd-grp
            then do:
                undo, return error "get-rkep-grp-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-id".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
function get-price-id-from-int returns character ( input p-file-num as integer):
  return ('price-list':U + chr(32) +  string(p-file-num)).
end function.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrglib_grp no-undo
    field sel           as character
    field full-name     as character
    field out-code      as integer
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field name          as character
    field level         as integer
    field mark          as character
    field obj-type      as character
    field obj-code      as integer
    field global-code   as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index nc is unique obj-type obj-code node-code
    index sl obj-type obj-code sel
    index uc obj-type obj-code upper-code
.
define temp-table temp_fbrglib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field obj-type      as character
    field obj-code      as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index lv obj-type obj-code level
    index it obj-type obj-code is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as integer
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure fbrglib-get-sort-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-obj-type
           and buf_fbr-gds-grp.obj-code  = p-obj-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if not available buf_fbr-gds-grp
    then do:
        undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while true
    on error undo, return error "fbrglib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_fbr-gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_fbr-gds-grp.upper-code
        .
        if buf_fbr-gds-grp.upper-code = 1
        then do:
            leave.
        end.
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
procedure fbrglib-get-full-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    if p-node-code = 1
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 1
        .
        do while true
        on error undo, return error "fbrglib-get-full-name: Ошибка составления полного имени группы"
        :
            assign
                p-full-name  = buf_fbr-gds-grp.node-name
                            + (if p-full-name <> "" then chr(47) else "")
                            + p-full-name
                v-upper-code = buf_fbr-gds-grp.upper-code
            .
            if buf_fbr-gds-grp.upper-code = 1
            then do:
                leave.
            end.
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = v-upper-code
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-node-code".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
procedure fbrglib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.upper-code = 0
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_fbr-gds-grp.node-code
        .
    end.
end.
end procedure.
procedure fbrglib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-obj-type     as character    no-undo.
define input parameter p-obj-code     as integer      no-undo.
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define variable v-node-name     as character      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run fbrglib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "fbrglib-find-grp-by-full-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_fbrglib_found-grp
    :
        delete temp_fbrglib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            assign
                v-node-name = entry( v-counter, p-search-name, chr(2) )
            .
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type   = p-obj-type
                   and buf_fbr-gds-grp.obj-code   = p-obj-code
                   and buf_fbr-gds-grp.upper-code = v-upper-code
                   and buf_fbr-gds-grp.node-name  = v-node-name
            no-error .
            if not available buf_fbr-gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(47) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_fbr-gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_fbr-gds-grp.node-name
                    v-upper-code = buf_fbr-gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name = v-full-name + chr(47)
                        temp_fbrglib_found-grp.sort-name = v-sort-name
                        temp_fbrglib_found-grp.node-code = v-upper-code
                        temp_fbrglib_found-grp.level     = v-counter
                        temp_fbrglib_found-grp.obj-type  = p-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-obj-code
                    .
                end.
            end.
        end.
        else do:
            for each buf_fbr-gds-grp no-lock
               where buf_fbr-gds-grp.obj-type   = p-obj-type
                 and buf_fbr-gds-grp.obj-code   = p-obj-code
                 and buf_fbr-gds-grp.upper-code = v-upper-code
                 and buf_fbr-gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_fbr-gds-grp.node-name
                    temp_fbrglib_found-grp.node-code = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.level     = v-level
                    temp_fbrglib_found-grp.obj-type  = p-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-obj-code
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_fbrglib_found-grp
                :
                    delete temp_fbrglib_found-grp.
                end.
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-full-name
    ).
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_fbr-gds-grp no-lock
           where buf_fbr-gds-grp.obj-type   = p-start-obj-type
             and buf_fbr-gds-grp.obj-code   = p-start-obj-code
             and buf_fbr-gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run fbrglib-is-terminal in this-procedure (
                  input buf_fbr-gds-grp.obj-type
                , input buf_fbr-gds-grp.obj-code
                , input buf_fbr-gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.is-terminal = yes
                    temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_fbr-gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                        temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                        temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                        temp_fbrglib_found-grp.is-terminal = no
                        temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-expand-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-start-name as character    no-undo.
define output parameter p-end-name  as character    no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_fbrglib_found-grp     for temp_fbrglib_found-grp.
    run fbrglib-find-grp-by-full-name in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-start-name
        , input no
    ) no-error.
    run fbrglib-get-max-substring in this-procedure (
           input p-obj-type
        ,  input p-obj-code
        ,  input length( p-start-name )
        , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_fbrglib_found-grp
             where temp_fbrglib_found-grp.full-name = p-end-name
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                     no-error.
        if available temp_fbrglib_found-grp
        then do:
            find first buf_temp_fbrglib_found-grp
                 where buf_temp_fbrglib_found-grp.full-name begins p-end-name
                   and recid( buf_temp_fbrglib_found-grp ) <> recid( temp_fbrglib_found-grp )
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
            no-error.
            if not available buf_temp_fbrglib_found-grp
            then do:
                run fbrglib-is-terminal in this-procedure (
                      input p-obj-type
                    , input p-obj-code
                    , input temp_fbrglib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-get-max-substring :
do
on error undo, return error
:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_fbrglib_found-grp  where
                   temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
        no-error.
        if not available temp_fbrglib_found-grp
        then do:
            undo, return error "fbrglib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_fbrglib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "fbrglib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_fbrglib_found-grp
                where temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_fbrglib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure fbrglib-is-terminal :
do
on error undo, return error "Ошибка процедуры fbrglib-is-terminal"
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type   = p-obj-type
           and buf_fbr-gds-grp.obj-code   = p-obj-code
           and buf_fbr-gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure fbrglib-have-goods :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-node-code          as integer      no-undo.
define output parameter p-have-fbr-gds-obj  as logical      no-undo.
    define buffer buf_fbr-gds-obj         for ub.fbr-gds-obj.
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type     = p-obj-type
           and buf_fbr-gds-obj.obj-code     = p-obj-code
           and buf_fbr-gds-obj.fbr-grp-code = p-node-code
    no-error .
    if available buf_fbr-gds-obj
    then do:
        assign
            p-have-fbr-gds-obj = yes
        .
    end.
    else do:
        assign
            p-have-fbr-gds-obj = no
        .
    end.
end.
end procedure.
procedure fbrglib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    search-grp:
    for each buf_fbr-gds-grp no-lock
        where buf_fbr-gds-grp.obj-type  = p-start-obj-type
          and buf_fbr-gds-grp.obj-code  = p-start-obj-code
          and buf_fbr-gds-grp.node-code > p-start-code
    :
        if index( buf_fbr-gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_fbr-gds-grp.node-code
                v-found      = yes
            .
            run fbrglib-get-full-name in this-procedure (
                  input p-start-obj-type
                , input p-start-obj-code
                , input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "fbrglib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure fbrglib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "fbrglib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
        end.
        if length( v-full-name ) + 1 + length( p-grp-name ) > 120
        then do:
            assign
                p-error-message = 'Полное название группы не может содержать более 120 символов.'
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-delete-grp :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-deleted   as logical      no-undo.
    define variable v-have-goods    as logical        no-undo.
    define variable v-yesno         as logical        no-undo.
    define variable v-upper-code    as integer        no-undo.
    define variable v-root-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj           for ub.fbr-gds-obj.
    define buffer buf_second_fbr-gds-grp    for ub.fbr-gds-grp.
    run fbrglib-get-root-code in this-procedure (
        output v-root-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "Не найден корневой узел." + chr(10) + return-value.
    end.
    if p-node-code = v-root-code
    then do:
        message
            "Корневую группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.upper-code   = p-node-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            "Не терминальную группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.node-code    = p-node-code
    .
    assign
        v-upper-code = buf_fbr-gds-grp.upper-code
    .
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ).
    if v-have-goods = yes
    then do:
        find first buf_second_fbr-gds-grp no-lock
             where buf_second_fbr-gds-grp.obj-type      = buf_fbr-gds-grp.obj-type
               and buf_second_fbr-gds-grp.obj-code      = buf_fbr-gds-grp.obj-code
               and buf_second_fbr-gds-grp.upper-code    = buf_fbr-gds-grp.upper-code
               and recid( buf_second_fbr-gds-grp )      <> recid( buf_fbr-gds-grp )
        no-error.
        if available buf_second_fbr-gds-grp
        then do:
            message
                "В группе есть товары,"
                skip "которые нельзя перенести в родительскую группу,"
                skip "потому что у родительской группы есть еще одна подгруппа."
                skip(1)
                skip "Перенесите товары в другую группу"
                skip "или удалите все остальные подгруппы родительской группы."
            view-as alert-box error.
            assign
                p-deleted = no
            .
            undo, return.
        end.
        message
            "В группе есть товары."
            skip "После удаления группы"
            skip "все ее товары будут привязаны"
            skip "к ее родительской группе."
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                for each buf_fbr-gds-obj exclusive-lock
                   where buf_fbr-gds-obj.obj-type     = p-obj-type
                     and buf_fbr-gds-obj.obj-code     = p-obj-code
                     and buf_fbr-gds-obj.fbr-grp-code = p-node-code
                on error undo, return error
                :
                    assign
                        buf_fbr-gds-obj.fbr-grp-code = v-upper-code
                    .
                end.
            end.
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error .
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
    else do:
        message
            "Имя группы: " buf_fbr-gds-grp.node-name
            "Код группы: " buf_fbr-gds-grp.node-code
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error.
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-add-grp :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define input parameter p-interface      as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-out-code       as integer      no-undo.
define input parameter p-global-code    as integer      no-undo.
define output parameter p-new-node-code as integer      no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-have-goods    as logical  no-undo.
    define variable v-host-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer bf_fbr-gds-grp        for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.upper-code = p-node-code
          AND buf_fbr-gds-grp.obj-type   = p-obj-type
          AND buf_fbr-gds-grp.obj-code   = p-obj-code
          AND buf_fbr-gds-grp.node-name  = p-node-name no-error .
    if available buf_fbr-gds-grp then do:
        if p-node-code <> 1 then do:
          find first buf_fbr-gds-grp no-lock where
                    buf_fbr-gds-grp.node-code = p-node-code
                AND buf_fbr-gds-grp.obj-type   = p-obj-type
                AND buf_fbr-gds-grp.obj-code   = p-obj-code  .
        end.
                message
        "Для объекта" p-obj-type p-obj-code
        "уже есть группа блюд" p-node-name "в подгруппе" (if p-node-code = 1 then "БЛЮДА" else buf_Fbr-gds-grp.node-name)
        view-as alert-box error .
        undo, return error .
    end.
    do transaction
    on error undo, return error
    :
        create buf_fbr-gds-grp.
        assign
            buf_fbr-gds-grp.node-code   = next-value( s-gds-grp, ub )
            p-new-node-code             = buf_fbr-gds-grp.node-code
            buf_fbr-gds-grp.upper-code  = p-node-code
            buf_fbr-gds-grp.host-code   = v-host-code
            buf_fbr-gds-grp.obj-type    = p-obj-type
            buf_fbr-gds-grp.obj-code    = p-obj-code
            buf_fbr-gds-grp.node-name    = ""
            buf_fbr-gds-grp.out-code    = 0
        .
        if p-interface then do:
          run ref/fbrggrpd.w (
                input parparentproc
              , input 'ИЗМЕНЕНИЕ':U
              , input p-obj-type
              , input p-obj-code
              , input buf_fbr-gds-grp.node-code
              , input buf_fbr-gds-grp.upper-code
              , input buf_fbr-gds-grp.node-name
              , input buf_fbr-gds-grp.out-code
              , output buf_fbr-gds-grp.node-name
              , output buf_fbr-gds-grp.out-code
              , output p-cancel
          ).
          if p-cancel = yes
          then do:
              delete buf_fbr-gds-grp.
              undo, return.
          end.
        end.
        else do:
          find first bf_fbr-gds-grp no-lock
              where bf_fbr-gds-grp.obj-type   = p-obj-type
                and bf_fbr-gds-grp.obj-code   = p-obj-code
                and bf_fbr-gds-grp.out-code   = p-out-code
          no-error.
          assign
          buf_fbr-gds-grp.node-name    = p-node-name
          buf_fbr-gds-grp.global-code  = p-global-code
          buf_fbr-gds-grp.out-code     = (if available bf_fbr-gds-grp then 0 else p-out-code)
          .
        end.
        if v-have-goods = yes
        then do:
            for each buf_fbr-gds-obj exclusive-lock
               where buf_fbr-gds-obj.obj-type      = p-obj-type
                 and buf_fbr-gds-obj.obj-code      = p-obj-code
                 and buf_fbr-gds-obj.fbr-grp-code  = p-node-code
            on error undo, return error
            :
                assign
                    buf_fbr-gds-obj.fbr-grp-code = p-new-node-code
                .
            end.
        end.
    end.
end.
end procedure.
do
on error undo, return error
:
FOR EACH gds-list:
  DELETE gds-list.
END.
assign
ii0 = num-entries(p-rid-list)
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
_ii:
DO ii = 1 TO ii0:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   FIND FIRST buf_cd-plu Exclusive-lock WHERE
            RECID(buf_cd-plu) = INTEGER(ENTRY(ii, p-rid-list)) NO-ERROR.
   IF not AVAILABLE  buf_cd-plu  THEN do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдена или занята запись товара на кассе R-keeper c recid &1", INTEGER(ENTRY(ii, p-rid-list)))).
      assign
      v-view-log = yes.
      next _ii.
   end.
   if buf_cd-plu.b-code = 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4 - не сопоставлен товар в системе IBS TH"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , chr(10)
                            )).
      assign
      v-view-log = yes.
      next _ii.
   end.
   find first buf_bar-code no-lock where
            buf_bar-code.b-code =  buf_cd-plu.b-code no-error.
   if not available buf_bar-code then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4 - не найден товар с бар-кодом &5 в системе IBS TH"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , chr(10)
                              , buf_cd-plu.b-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
   end.
   find first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code  no-error no-wait.
   if not available buf_goods and not locked buf_goods then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4 - не найден товар с кодом &5 для бар-кода &6 в системе IBS TH"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , chr(10)
                              , buf_cd-plu.b-code
                              , buf_bar-code.gds-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
   end.
  find first buf_fbr-gds-obj exclusive-lock where
            buf_fbr-gds-obj.gds-code = buf_goods.gds-code
        AND buf_fbr-gds-obj.obj-type = p-curr-obj-type
        AND buf_fbr-gds-obj.obj-code = p-curr-obj-code no-wait no-error.
  if locked buf_fbr-gds-obj then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                              " - атрибуты РЕСТОРАН для товара с кодом &5 - запись ЗАНЯТА"
                            , buf_cd-plu.plu-code
                            , buf_cd-plu.key#_one
                            , buf_cd-plu.charkey_one
                            , chr(10)
                            , buf_cd-plu.b-code
                          )).
    assign
    v-view-log = yes.
    next _ii.
  end.
  if available buf_Fbr-gds-obj then do:
    assign
    v-rid = recid(buf_Fbr-gds-obj)
    .
  end.
  find first buf_fbr-gds-grp no-lock where
            buf_fbr-gds-grp.out-code = buf_cd-plu.key#_two
        AND buf_fbr-gds-grp.obj-type = p-curr-obj-type
        AND buf_fbr-gds-grp.obj-code = p-curr-obj-code no-error .
  if not available buf_fbr-gds-grp then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                              "- не найдена группа блюд для &5&6 с кодом на кассе =&7"
                            , buf_cd-plu.plu-code
                            , buf_cd-plu.key#_one
                            , buf_cd-plu.charkey_one
                            , chr(10)
                            , p-curr-obj-type
                            , p-curr-obj-code
                            , buf_cd-plu.key#_two
                          )).
    assign
    v-view-log = yes.
    next _ii.
  end.
  if not available buf_fbr-gds-obj
  or buf_fbr-gds-obj.fbr-grp-code <> buf_fbr-gds-grp.node-code then do:
    run ref/fgdsobj1.p (
                    input-output    v-rid
                    ,input (if available buf_fbr-gds-obj then 'ИЗМЕНЕНИЕ':U else 'ДОБАВЛЕНИЕ':U)
                    ,input yes
                    ,input buf_goods.gds-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input buf_fbr-gds-grp.node-code
                    ,input (if available buf_fbr-gds-obj
                          then buf_fbr-gds-obj.fbr-obj-type
                          else "":U)
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.fbr-obj-code
                            else 0)
                    ,input yes
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-menu
                            else no)
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-modificator
                            else no)
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-null-price
                            else no)
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-season
                            else no)
                    ,input (if available buf_fbr-gds-obj
                            then buf_fbr-gds-obj.is-semi-finished
                            else no)
                    ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4" +
                            " - не удалось синхронизировать с товар с кодом &5 по группе:&4&6 &7"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , chr(10)
                              , buf_cd-plu.b-code
                              , error-status:get-message(1)
                              , return-value
                            )).
      assign
      v-view-log = yes.
      next _ii.
    end.
  end.
  buf_cd-plu.logkey_three = no.
  ii-ok = ii-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Обработано &1 блюд, из них упешно &2"
                                    , ii
                                    , ii-ok
                                    )) no-error.
  run get-stop-state in p-log-handle(output v-stop-state).
  if v-stop-state then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Процесс прерван пользователем"
                          )).
    assign
    v-view-log = yes.
    LEAVE _II.
  end.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "!!!Из &1 товаров успешно по названию синхронизировано &2"
                        , ii0
                        , ii-ok
                      )).
end.
