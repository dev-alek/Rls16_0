block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: z-tot2.p $
$Archive: cus/z-tot2.p $

Экспорт в формат мобильного сканера

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-doc-type as character no-undo .
define input parameter p-other    as character no-undo .
define input parameter p-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tot2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tot2.p $":U .
define variable vss-description as character no-undo init "Экспорт в формат мобильного сканера" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/waitfram.i }

define variable h-query  as handle no-undo .
define variable h-buffer as handle no-undo .
define variable h-goods  as handle no-undo .

define variable v-table-name    as character no-undo .
define variable v-field-name    as character no-undo .
define variable v-field-name2   as character no-undo init "".
define variable v-field-name0   as character no-undo .
define variable v-query-prepare as character no-undo .
define variable v-gds-code as integer   no-undo .
define variable v-qnty as decimal   no-undo .
define variable v-price as decimal   no-undo .
define variable l-filename as character no-undo .
define variable s-bar-code like ub.bar-code.b-code no-undo .
define variable g#log as logical   no-undo .
define variable l-ok  as logical no-undo .

define stream OutStream .

message "Проводить экспорт  в формат мобильного сканера ? " skip
  "Документ " p-doc-code
  view-as alert-box question
  buttons yes-no
  update l-ok .

if not l-ok then return.

case p-doc-type :
  when "order" then
        assign
          v-table-name = "ub.ord-line"
          v-field-name = "qnty"
        .
  when "rcv" then
        assign
          v-table-name = "ub.ord-line-rcv"
          v-field-name = "qnty"
          v-field-name2 = "price-rubl"
        .

  when "trn-doc" then do:
        if p-other = "doc" then
            assign
              v-table-name = "ub.doc-line"
              v-field-name = "doc-qnty"
            .
        if p-other = "fact" then
              assign
                v-table-name = "ub.doc-line"
                v-field-name = "fact-qnty"
             .
        if p-other = "inv" then
              assign
                v-table-name = "ub.doc-line"
                v-field-name = "doc-qnty"
             .

  end.
end case.

l-filename = p-doc-type + p-doc-code + ".txt" .
system-dialog get-file  l-filename
    ask-overwrite
    save-as
    create-test-file
    use-filename
    update g#log
    default-extension "txt" .

 if g#log then
   Output stream OutStream to value( l-filename ) .
   else return .

run waitfram-show ("Ждите...") .


create buffer h-buffer for table v-table-name.
create buffer h-goods  for table "ub.goods" .
create query h-query.

v-query-prepare = substitute("for each &1 no-lock where &1.doc-code = '&2' , each ub.goods no-lock where
                  ub.goods.artic = &1.artic and
                  ub.goods.prod-type = &1.prod-type and
                  ub.goods.prod-code = &1.prod-code "
                  , v-table-name , p-doc-code ).
if p-doc-type = 'rcv' then
    v-query-prepare = substitute("for each &1 no-lock where &1.rcv-code = '&2' , each ub.goods no-lock where
                      ub.goods.artic = &1.artic and
                      ub.goods.prod-type = &1.prod-type and
                      ub.goods.prod-code = &1.prod-code "
                      , v-table-name , p-doc-code ).

  h-query:set-buffers(h-buffer,h-goods).
  h-query:query-prepare(v-query-prepare).
  h-query:query-open.
  h-query:get-first ( no-lock  ) .
  do while h-buffer:available :
     v-gds-code  = h-goods:buffer-field("gds-code"):buffer-value .
     v-qnty      = h-buffer:buffer-field(v-field-name):buffer-value .
     v-price     = h-buffer:buffer-field(v-field-name2):buffer-value no-error .
     { gbl/gdsbcode.i v-gds-code  ? s-bar-code }

     put stream  OutStream unformatted
        s-bar-code
        ","
        trim(string(v-qnty, ">>>>>>>>>>9.<<<" ))
        .
        if v-price <> ? and v-price <> 0 then
            put stream  OutStream unformatted
              ","
              trim(string(v-price, ">>>>>>>>>>>9.999" ))
              .
      put stream  OutStream unformatted
        {&new-line}
        .

     h-query:get-next ( no-lock  ) .
  end.

  h-query:query-close().
  output stream OutStream close.
  run waitfram-hide .


delete widget h-buffer.
delete widget h-goods.
delete widget h-query.
