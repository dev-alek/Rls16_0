/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица хранящая номера автодокументов по продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/03/05
Author: Bakhtadze Natalya
Creation date: 10/03/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(tsaledoc_i) = 0 or "{3}" <> "" &then



&glob tsaledoc_i


define {1} temp-table
&if "{3}" <> "" &then {3} &else temp-sale-doc &endif no-undo like ub.trn-doc
field doc-kind as character
field doc-label as character
field recid_ as recid
field order as integer
field gds-amount as integer /*кол-во строк чеков*/
field chk-amount as integer /*кол-во чеков*/
field tot-dtl as integer /*кол-во gds-dtl*/
field msign as integer init 1
field main as logical
field in-inkas  as logical
field filled as logical /*непустая*/
field chk-doc-code like ub.chk-doc.doc-code
field alias-type-price  as character
field price-obj-type    like ub.clients.obj-type
field price-obj-code    like ub.clients.obj-code
field dir_ as integer
field fbrsale  as logical
field table_ as character
field main-receipt-type as integer
field poss-wro-codes as character
index pi is unique primary
doc-code
table_
index ihobj host-code obj-type obj-code
index iobj obj-type obj-code
index iedt ext-doc-type
index ikind doc-kind
index iorder order
index ifill filled
index ifbrsale fbrsale
.


&if "{3}" = "" &then

FUNCTION set-sale-doc-PS returns character( buffer buf_temp-sale-doc for temp-sale-doc):
define variable v-ps as character no-undo .
&scop sale-doc-kind buf_temp-sale-doc.doc-kind
if available buf_temp-sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , {&delim-par}
                    , (if buf_temp-sale-doc.office then "УСЛУГИ." else "ТОВАРЫ." )
                    , {&sale-doc-name}
                    , buf_temp-sale-doc.chk-amount
                    , buf_temp-sale-doc.gds-amount
                    , buf_temp-sale-doc.tot-lines
                    , buf_temp-sale-doc.tot-dtl
                    ).
else  do:
&scop sale-doc-kind {&TDEDT_Ras_Vnesh_KASS}
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , {&delim-par}
                    , '':U
                    , {&sale-doc-name}
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.

PROCEDURE get-sale-doc-PS:
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define parameter buffer buf_temp-sale-doc for temp-sale-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
assign
buf_temp-sale-doc.chk-amount = int(entry(2, entry(4, buf_temp-sale-doc.ps, {&delim-par}), {&space-char} ))
buf_temp-sale-doc.gds-amount = int(entry(2, entry(5, buf_temp-sale-doc.ps, {&delim-par}), {&space-char} ))
buf_temp-sale-doc.tot-lines = buf_temp-sale-doc.tot-lines
buf_temp-sale-doc.tot-dtl = int(entry(2, entry(7, buf_temp-sale-doc.ps, {&delim-par}), {&space-char} ))
no-error .
if error-status:error then do:
  if session:set-wait-state("compiler") then.
  assign
  buf_temp-sale-doc.chk-amount = 0
  buf_temp-sale-doc.gds-amount = 0
  buf_temp-sale-doc.tot-lines = 0
  buf_temp-sale-doc.tot-dtl = 0
  .
  for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_temp-sale-doc.doc-code:
    assign
    buf_temp-sale-doc.tot-lines = buf_temp-sale-doc.tot-lines + 1
    .
  end.
  for each buf_gds-dtl no-lock where buf_gds-dtl.doc-code = buf_temp-sale-doc.doc-code:
    assign
    buf_temp-sale-doc.tot-dtl = buf_temp-sale-doc.tot-dtl + 1.
  end.
  _chk-doc:
  for each buf_chk-doc no-lock where
          buf_chk-doc.out-code = p-inkas-code:
      if buf_temp-sale-doc.main-receipt-type = buf_chk-doc.chk-type then do:
        assign
        buf_temp-sale-doc.chk-amount = buf_temp-sale-doc.chk-amount  + 1
        .
      END.
      if buf_temp-sale-doc.doc-type <> {&write-off}
      and buf_temp-sale-doc.main-receipt-type <> buf_chk-doc.chk-type then do:
        next _chk-doc.
      end.
      _chk-gds:
      for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code:
        if buf_chk-gds.doc-qnty = 0 then next _chk-gds.
        if buf_temp-sale-doc.doc-type = {&write-off} then do:
         if (buf_chk-gds.write-off-code = 0
             or
             buf_chk-gds.write-off-code = ?
             ) then next _chk-gds.
          if LOOKUP(string(buf_chk-gds.write-off-code), buf_temp-sale-doc.poss-wro-codes, ';') = 0 then next _chk-gds.
        end.
&scop wro-code string(buf_chk-gds.write-off-code)
        if buf_temp-sale-doc.doc-type <> {&write-off} then do:
          if (buf_chk-gds.write-off-code <> ?
              and
              buf_chk-gds.write-off-code <> 0
              )
          and not {&wro-is-modificator}   then next _chk-gds.
        end.
        assign
        buf_temp-sale-doc.gds-amount = buf_temp-sale-doc.gds-amount  + 1
        .
      end.
  end. /*  for each buf_chk-doc no-lock where*/
  if session:set-wait-state("") then.
end.
END PROCEDURE.

FUNCTION get-sale-doc-kind returns character(input p-doc-code as character
                                           , input p-out-code as character
                                           , input p-doc-type as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
if p-ext-doc-type = {&TDEDT_Ras_vnesh_kass} then do:
  assign
  p-order = 1
  p-msign = 1
  p-main = yes
  p-in-inkas = yes
  p-dir_ = 1
  .
  return p-ext-doc-type.
end.
if p-ext-doc-type = {&TDEDT_vozvrat_vnesh_kass} then do:
  assign
  p-order = 2
  p-msign = - 1
  p-main = no
  p-in-inkas = yes
  p-dir_ = - 1
  .
  return p-ext-doc-type.
end.
if p-doc-type = {&write-off} then do:
  run gbl/trdcat-v.p (
        input p-out-code
      , input {&trdcattr-we-return-write-off}
      , output v-value
      , output v-type
  ).
  if v-value = p-doc-code then  do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 3
    p-dir_ = 1
    .
    return {&sale-add-return-write-off}.
  end.
  run gbl/trdcat-v.p (
        input p-out-code
      , input {&trdcattr-we-tech-refuell}
      , output v-value
      , output v-type
 ).
 if v-value = p-doc-code then  do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 4
   p-dir_ = 1
   .
   return {&sale-add-tech-refuell}.
 end.
 run gbl/trdcat-v.p (
       input p-out-code
     , input {&trdcattr-we-write-off}
     , output v-value
     , output v-type
 ).
 if v-value = p-doc-code then  do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  5
   p-dir_ = 1
   .
   return {&sale-add-write-off}.
 end.

end.
/*другие неопределенные типы документов*/
assign
p-msign = 1
p-main = no
p-in-inkas = no
p-order = -1.
return p-ext-doc-type.
END FUNCTION.


&if "{2}" = "proc" &then

procedure tsaledoc-fill :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .

/*номера документов списания*/
define variable v-dop as character no-undo .
define variable v-type as character no-undo .
define variable v-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable ii as integer no-undo .
define variable v-attr-code as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-fact as logical no-undo .
define variable v-ret-code like ub.trn-doc.doc-code no-undo .
define variable v-dir_ as integer no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_temp-sale-doc for temp-sale-doc.
define buffer buf2_temp-sale-doc for temp-sale-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_fbr-doc for ub.fbr-doc.

  do
  on error undo, return error return-value
  :
    for each buf_temp-sale-doc:
      delete buf_temp-sale-doc.
    end.
    /*запишем всю эту фигню в temp-table*/
&scop sale-doc-kind buf_temp-sale-doc.doc-kind
    do ii = 1 to num-entries({&sale-add-kinds}) :
      if ii = 1 then do:
        assign
        v-attr-code = {&trdcattr-we-return-write-off}
        .
      end.
      if ii = 2 then do:
        assign
        v-attr-code = {&trdcattr-we-tech-refuell}
        .
      end.
      if ii = 3 then do:
        assign
        v-attr-code = {&trdcattr-we-write-off}
        .
      end.
      run gbl/trdcat-v.p (
            input p-inkas-code
          , input v-attr-code
          , output v-attr-value
          , output v-type
      ) no-error.
      if error-status:error then do:
        undo, return error substitute("ошибка получения значения атрибута документа &1 &2:&3&4 &5"
                                      ,p-inkas-code
                                      , v-attr-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                    ).
      end.
&scop sale-doc-kind buf_temp-sale-doc.doc-kind
      if v-attr-value <> ?
      and v-attr-value <> '':U then do:
        find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = v-attr-value no-error .
        if available buf_trn-doc then do:
          create buf_temp-sale-doc.
          buffer-copy buf_trn-doc
          to buf_temp-sale-doc
          assign
          buf_temp-sale-doc.table_ =  {&table_trn-doc}
          buf_temp-sale-doc.doc-kind  = entry(ii, {&sale-add-kinds})
          buf_temp-sale-doc.recid_  = recid(buf_trn-doc)
          buf_temp-sale-doc.order   = 2 + ii
          buf_temp-sale-doc.msign = (if buf_temp-sale-doc.doc-kind = {&sale-add-return-write-off} then - 1 else 1)
          buf_temp-sale-doc.main = no
          buf_temp-sale-doc.in-inkas = no
          buf_temp-sale-doc.dir_ = 1
          buf_temp-sale-doc.fbrsale = lookup(buf_temp-sale-doc.doc-kind,  {&sale-doc-fbrsale}) > 0
          .
          assign
          buf_temp-sale-doc.filled   = buf_temp-sale-doc.fact-qnty <> 0 or buf_temp-sale-doc.tot-lines <> 0
&scop sale-doc-kind buf_temp-sale-doc.doc-kind
          buf_temp-sale-doc.doc-label  = {&sale-doc-name}
          buf_temp-sale-doc.main-receipt-type = integer({&sale-doc-main-receipt-type})
          buf_temp-sale-doc.poss-wro-codes = {&sale-doc-poss-wro-codes}
          .
          run get-sale-doc-ps in this-procedure (input p-inkas-code, buffer buf_temp-sale-doc).
        end. /*if available buf_trn-doc then do:*/
      end. /*   if v-attr-value <> ?
                and v-attr-value <> '':U then do:    */
    end. /*ii = 1 to num-entries({&sale-add-kinds}) :*/
  &scop sale-doc-kind buf_temp-sale-doc.doc-kind
  _II:
  do ii = 1 to 2:
    if ii = 1 then do:
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = p-inkas-code no-error .
       assign
       v-ret-code = buf_trn-doc.out-code
       .
    end.
    if ii = 2 then do:
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = v-ret-code no-error .
    end.
    if not available buf_trn-doc then next _II.
    if buf_trn-doc.status_ = {&fact} then v-fact = yes.
    create buf_temp-sale-doc.
    buffer-copy buf_trn-doc
    to buf_temp-sale-doc.
    assign
    buf_temp-sale-doc.recid_ = recid(buf_trn-doc)
    buf_temp-sale-doc.table_ =  {&table_trn-doc}
    no-error .
    assign
    buf_temp-sale-doc.doc-kind = get-sale-doc-kind (input buf_temp-sale-doc.doc-code,
    input p-inkas-code, input buf_temp-sale-doc.doc-type, input buf_temp-sale-doc.ext-doc-type
    , output v-order, output v-msign, output v-main, output v-in-inkas, output v-dir_)
    buf_temp-sale-doc.doc-label = {&sale-doc-name}
    buf_temp-sale-doc.order = v-order
    buf_temp-sale-doc.main = v-main
    buf_temp-sale-doc.in-inkas = v-in-inkas
    buf_temp-sale-doc.msign = v-msign
    buf_temp-sale-doc.dir_ = v-dir_
    buf_temp-sale-doc.fbrsale = lookup(buf_temp-sale-doc.doc-kind, {&sale-doc-fbrsale}) > 0
    buf_temp-sale-doc.main-receipt-type = (if v-order > 0 then integer({&sale-doc-main-receipt-type}) else ?)
    buf_temp-sale-doc.poss-wro-codes = (if v-order > 0 then {&sale-doc-poss-wro-codes} else '':U)
    .
    run get-sale-doc-ps in this-procedure (input p-inkas-code, buffer buf_temp-sale-doc).
    assign
    buf_temp-sale-doc.filled   = buf_temp-sale-doc.fact-qnty <> 0 or buf_temp-sale-doc.tot-lines <> 0
    .
  end. /*i do ii*/
&scop create-no-auto-temp-sale-doc                                                                                      ~
          create ~{&my-temp-buffer~}.                                                                                     ~
          buffer-copy ~{&my-buffer~}                                                                                       ~
          to ~{&my-temp-buffer~}.                                                                                         ~
          assign                                                                                                        ~
          ~{&my-temp-buffer~}.recid_ = recid(~{&my-buffer~})                                                                 ~
          no-error .                                                                                                    ~
          assign                                                                                                        ~
          ~{&my-temp-buffer~}.table_ =  ~{&table_trn-doc~}                                                                ~
          ~{&my-temp-buffer~}.doc-kind = ~{&my-buffer~}.ext-doc-type                                                      ~
          ~{&my-temp-buffer~}.doc-label = entry(lookup(~{&my-buffer~}.ext-doc-type, ~{&TDEDT_list~}), ~{&TDEDT_list-full~})  ~
          ~{&my-temp-buffer~}.order =  - 1                                                                                ~
          ~{&my-temp-buffer~}.main = no                                                                                   ~
          ~{&my-temp-buffer~}.in-inkas = no                                                                               ~
          ~{&my-temp-buffer~}.msign = 1                                                                                   ~
          ~{&my-temp-buffer~}.filled   = ~{&my-temp-buffer~}.fact-qnty <> 0 or ~{&my-temp-buffer~}.tot-lines <> 0             ~
          ~{&my-temp-buffer~}.doc-qnty = (if ~{&my-temp-buffer~}.ext-doc-type = ~{&TDEDT_Chg_Purch_Code~}                   ~
                                        then ?                                                                          ~
                                        else ~{&my-temp-buffer~}.doc-qnty)                                                ~
          ~{&my-temp-buffer~}.fact-qnty = (if ~{&my-temp-buffer~}.ext-doc-type = ~{&TDEDT_Chg_Purch_Code~}                  ~
                                        then ?                                                                          ~
                                        else ~{&my-temp-buffer~}.fact-qnty)


  if v-fact then do:
      for each buf_trn-doc no-lock where
              buf_trn-doc.out-code = p-inkas-code:
        find first buf_temp-sale-doc where
                buf_temp-sale-doc.doc-code = buf_trn-doc.doc-code no-error .
        if not available buf_temp-sale-doc then do:

&scop my-buffer  buf_trn-doc
&scop my-temp-buffer  buf_temp-sale-doc
        {&create-no-auto-temp-sale-doc}.
        end. /*if not available buf_temp-sale-doc then do:*/
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_temp-sale-doc.doc-code:
          find first buf2_temp-sale-doc where
                  buf2_temp-sale-doc.doc-code = buf2_trn-doc.doc-code no-error .
          if not available buf2_temp-sale-doc then do:
&scop my-buffer  buf2_trn-doc
&scop my-temp-buffer  buf2_temp-sale-doc
            {&create-no-auto-temp-sale-doc}.
          end.
        end.
      end. /*for each buf_trn-doc no-lock where*/
      for each buf_fbr-doc no-lock where
            buf_fbr-doc.out-code = p-inkas-code:
        for each buf_trn-doc no-lock where
             buf_trn-doc.out-code = buf_fbr-doc.doc-code
        by buf_trn-doc.fact-order
        on error undo, return error:
          if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Prvo}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
          then do:        /* Добавляем в таблицу только документы, порожденные документом производства */
            find first buf_temp-sale-doc where
                    buf_temp-sale-doc.doc-code = buf_trn-doc.doc-code
                AND buf_temp-sale-doc.table_ = {&table_trn-doc}
                    no-error .
            if not available buf_temp-sale-doc then do:
  &scop my-buffer  buf_trn-doc
  &scop my-temp-buffer  buf_temp-sale-doc
            {&create-no-auto-temp-sale-doc}.
            end.
            if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo} then do:
              assign
              v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
              v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
              v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
              .
            end.
            for each buf2_trn-doc no-lock where
                    buf2_trn-doc.out-code = buf_temp-sale-doc.doc-code:
              find first buf2_temp-sale-doc where
                      buf2_temp-sale-doc.doc-code = buf2_trn-doc.doc-code
                  AND buf2_temp-sale-doc.table_ = {&table_trn-doc} no-error .
              if not available buf2_temp-sale-doc then do:
    &scop my-buffer  buf2_trn-doc
    &scop my-temp-buffer  buf2_temp-sale-doc
                {&create-no-auto-temp-sale-doc}.
              end.
            end.
          end.
        end.
        find first buf_temp-sale-doc where
                  buf_temp-sale-doc.table_ = {&table_fbr-doc}
             AND buf_temp-sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
        if not available buf_temp-sale-doc then do:
          create buf_temp-sale-doc.
          assign
          buf_temp-sale-doc.table_ =  {&table_fbr-doc}
          buf_temp-sale-doc.doc-type      = {&manufacturing}
          buf_temp-sale-doc.doc-code      = buf_fbr-doc.doc-code
          buf_temp-sale-doc.ext-doc-type  = {&manufacturing}
          buf_temp-sale-doc.obj-type      = buf_fbr-doc.obj-type
          buf_temp-sale-doc.obj-code      = buf_fbr-doc.obj-code
          buf_temp-sale-doc.cli-type      = buf_fbr-doc.obj-type
          buf_temp-sale-doc.cli-code      = buf_fbr-doc.obj-code
          buf_temp-sale-doc.doc-label     = {&manufacturing}
          buf_temp-sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
          buf_temp-sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
          buf_temp-sale-doc.tot-lines     = v-pri-prvo-tot-lines
          buf_temp-sale-doc.tot-dtl       = v-pri-prvo-tot-lines
          .
        end.
      end. /*      for each buf_fbr-doc no-lock where*/
    end. /*if v-fact then do:*/
  end. /*doe*/


end procedure. /* ttpsidoc-fill */

procedure tsaledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.

define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .

define buffer buf_temp-sale-doc for temp-sale-doc.
   find first buf_temp-sale-doc where
            buf_temp-sale-doc.doc-kind = p-doc-kind no-error .
   if not available buf_temp-sale-doc  then do:
      create buf_temp-sale-doc.
      assign
      buf_temp-sale-doc.table_ =  {&table_trn-doc}
      buf_temp-sale-doc.host-code = p-host-code
      buf_temp-sale-doc.obj-type = p-obj-type
      buf_temp-sale-doc.obj-code = p-obj-code
      buf_temp-sale-doc.doc-kind  = p-doc-kind
      buf_temp-sale-doc.order = lookup(p-doc-kind, {&sale-all-doc-kinds})
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_temp-sale-doc
   assign
   buf_temp-sale-doc.recid_  = recid(buf_trn-doc)
   .
&scop sale-doc-kind buf_temp-sale-doc.doc-kind
  assign
  buf_temp-sale-doc.doc-kind = get-sale-doc-kind (input buf_temp-sale-doc.doc-code,
  input p-inkas-code, input buf_temp-sale-doc.doc-type, input buf_temp-sale-doc.ext-doc-type
  , output v-order, output v-msign, output v-main
  , output v-in-inkas, output v-dir_)
  buf_temp-sale-doc.doc-label = {&sale-doc-name}
  buf_temp-sale-doc.order = v-order
  buf_temp-sale-doc.main = v-main
  buf_temp-sale-doc.in-inkas = v-in-inkas
  buf_temp-sale-doc.msign = v-msign
  buf_temp-sale-doc.dir_ = v-dir_
  buf_temp-sale-doc.fbrsale = lookup(buf_temp-sale-doc.doc-kind, {&sale-doc-fbrsale}) > 0
  buf_temp-sale-doc.main-receipt-type = integer({&sale-doc-main-receipt-type})
  buf_temp-sale-doc.poss-wro-codes = {&sale-doc-poss-wro-codes}
  .
END.

&endif
/*if "{3}" = ""*/

&endif
/*if "{2}" = "proc" */

&endif
/*&if defined(tsaledoc_i) = 0 or "{3}" <> "" &then*/


/* $Workfile$   E n d */
