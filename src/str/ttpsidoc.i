/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Массив документов цепочки закрытия продаже в ТПСИ -Временная таблица и процедура заполнени
должен быть определен  t r d c a l i b . i

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/04
Author: Bakhtadze Natalya
Creation date: 12/02/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-tpsi-doc no-undo like ub.trn-doc
field doc-kind as character
field doc-label as character
field recid_ as recid
field order as integer
field alias-type-price  as character
field price-obj-type    like ub.clients.obj-type
field price-obj-code    like ub.clients.obj-code
field tot-dtl as integer /*кол-во gds-dtl*/
index pi is unique primary
doc-code
index ihobj host-code obj-type obj-code
index iobj obj-type obj-code
index iedt ext-doc-type
.

define {1} temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.






define {1} temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define {1} temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
/*!!!!!!!!!!!!!!!!ВНИМАНИЕ!!!!!!!!!!!!!!!*/
/*в doc-qnty - лежит количество зарезервированное для нас в чужом документе*/
/*в fact-qnty -
перед передачей  СУСЛОВУ лежит количество необходимое для резервирования*/


define {1} temp-table tt0-parts    no-undo like ub.parts.
define {1} temp-table temp-tpsi-clients  no-undo like ub.clients.


&if "{2}" = "proc" &then

FUNCTION set-tpsi-doc-PS returns character( buffer buf_temp-tpsi-doc for temp-tpsi-doc):
define variable v-ps as character no-undo .
&scop tpsi-doc-ext buf_temp-tpsi-doc.ext-doc-type
assign
v-PS = substitute('@&1 для закрытия продажи &2 на &3&4&5товаров &6&5признаков &7'
                  , {&tpsi-doc-name-e}
                  , buf_temp-tpsi-doc.out-code
                  , buf_temp-tpsi-doc.obj-type
                  , buf_temp-tpsi-doc.obj-code
                  , {&delim-par}
                  , buf_temp-tpsi-doc.tot-lines
                  , buf_temp-tpsi-doc.tot-dtl
                  ).
return v-Ps.
END FUNCTION.


PROCEDURE get-tpsi-doc-PS:
define parameter buffer buf_temp-tpsi-doc for temp-tpsi-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
assign
buf_temp-tpsi-doc.tot-lines = buf_temp-tpsi-doc.tot-lines
buf_temp-tpsi-doc.tot-dtl = int(entry(2, entry(7, buf_temp-tpsi-doc.ps, {&delim-par}), {&space-char} ))
no-error .
if error-status:error then do:
  assign
  buf_temp-tpsi-doc.tot-lines = 0
  buf_temp-tpsi-doc.tot-dtl = 0
  .
  for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_temp-tpsi-doc.doc-code:
    assign
    buf_temp-tpsi-doc.tot-lines = buf_temp-tpsi-doc.tot-lines + 1
    .
  end.
  for each buf_gds-dtl no-lock where buf_gds-dtl.doc-code = buf_temp-tpsi-doc.doc-code:
    assign
    buf_temp-tpsi-doc.tot-dtl = buf_temp-tpsi-doc.tot-dtl + 1.
  end.
end.
END PROCEDURE.



&scop  add-from-db ~
     for each buf_trn-doc where                                                              ~
            buf_trn-doc.out-code = p-inkas-code:                                             ~
      if buf_trn-doc.ext-doc-type <> ~{&TDEDT_RAS_Perem~}                                    ~
      AND buf_trn-doc.ext-doc-type <> ~{&TDEDT_RAS_Vnesh~} then NEXT.                        ~
      find first temp-tpsi-doc where                                                         ~
                temp-tpsi-doc.doc-code = buf_trn-doc.doc-code no-error .                     ~
      if not available temp-tpsi-doc then do:                                                ~
        run get-alias-type-price-obj  in this-procedure (                                    ~
     /*получени етипа цены перемещения и объекта для взятия цены для пары ОБЪЕКТ ПРОДАЖИ - ОБЪЕКТ ПЕРЕМЕЩЕНИЯ*/  ~
                                                          input  p-host-code                 ~
                                                          ,input p-obj-type                  ~
                                                          ,input p-obj-code                  ~
                                                          ,input buf_trn-doc.host-code       ~
                                                          ,input buf_trn-doc.obj-type        ~
                                                          ,input buf_trn-doc.obj-code        ~
                                                          ,output v-ext-doc-type             ~
                                                          ,output v-alias-type-price         ~
                                                          ,output v-price-obj-type           ~
                                                          ,output v-price-obj-code).         ~
        create temp-tpsi-doc.                                                                ~
        assign                                                                               ~
        temp-tpsi-doc.host-code = buf_trn-doc.host-code                                      ~
        temp-tpsi-doc.obj-type  = buf_trn-doc.obj-type                                       ~
        temp-tpsi-doc.obj-code  = buf_trn-doc.obj-code                                       ~
        temp-tpsi-doc.doc-code  = buf_trn-doc.doc-code                                       ~
        temp-tpsi-doc.cli-type  = buf_trn-doc.cli-type                                       ~
        temp-tpsi-doc.cli-code  = buf_trn-doc.cli-code                                       ~
        temp-tpsi-doc.cli-name  = buf_trn-doc.cli-name                                       ~
        temp-tpsi-doc.ext-doc-type = buf_trn-doc.ext-doc-type                                ~
        temp-tpsi-doc.alias-type-price = v-alias-type-price                                  ~
        temp-tpsi-doc.price-obj-type   = v-price-obj-type                                    ~
        temp-tpsi-doc.price-obj-code   = v-price-obj-code                                    ~
        temp-tpsi-doc.out-code  = buf_trn-doc.out-code                                       ~
        temp-tpsi-doc.doc-qnty =  buf_trn-doc.doc-qnty                                       ~
        temp-tpsi-doc.fact-qnty =  buf_trn-doc.fact-qnty                                     ~
        temp-tpsi-doc.tot-lines =  buf_trn-doc.tot-lines                                     ~
        no-error                                                                             ~
        .                                                                                    ~
      end.                                                                                   ~
      else do:                                                                               ~
        assign                                                                               ~
        temp-tpsi-doc.doc-qnty =  buf_trn-doc.doc-qnty                                       ~
        temp-tpsi-doc.fact-qnty =  buf_trn-doc.fact-qnty                                     ~
        temp-tpsi-doc.tot-lines =  buf_trn-doc.tot-lines                                     ~
        .                                                                                    ~
      end.                                                                                   ~
      run get-tpsi-doc-PS in this-procedure ( buffer temp-tpsi-doc ).                        ~
    end

    /*без точки для проверки синтаксиса*/


    /*без точки для проверки синтаксиса*/



procedure ttpsidoc-fill :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-add-from-db as logical no-undo .

define variable jj as integer no-undo .
/*номера связанных документов при закрытии ТПСИ - расходные части относящиеся к объектам собственникам товаров*/
define variable v-hold-ee-code    as character no-undo .
define variable v-ev-code         as character no-undo .
define variable v-dop as character no-undo .
define variable v-type as character no-undo .
define variable v-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define variable v-alias-type-price as character no-undo .
define variable v-price-obj-type like ub.clients.obj-type no-undo .
define variable v-price-obj-code like ub.clients.obj-code no-undo .
define buffer buf_clients for ub.clients.


define buffer buf_trn-doc for ub.trn-doc.
  do
  on error undo, return error return-value
  :

    for each temp-tpsi-doc:
      delete temp-tpsi-doc.
    end.
    { str/tdat-val.i
        p-inkas-code
        {&trdcattr-hold-ee-tpsi-code}
        v-hold-ee-code
        v-type
        no-error
    }
    if error-status :error then do:
      undo, return error substitute( "ошибка получения значения атрибута документа &1 &2:&3&4 &5"
                                   , p-inkas-code
                                   , {&trdcattr-hold-ee-tpsi-code}
                                   , {&new-line}
                                   , error-status :get-message( 1 )
                                   , return-value
                                   ) .
    end.
    { str/tdat-val.i
        p-inkas-code
        {&trdcattr-ev-tpsi-code}
        v-ev-code
        v-type
        no-error
    }
    if error-status :error then do:
      undo, return error substitute( "ошибка получения значения атрибута документа &1 &2:&3&4 &5"
                                   , p-inkas-code
                                   , {&trdcattr-ev-tpsi-code}
                                   , {&new-line}
                                   , error-status :get-message( 1 )
                                   , return-value
                                   ) .
    end.
    /*запишем всю эту фигню в temp-table*/
    if v-hold-ee-code <> ?
    and v-hold-ee-code <> "":U
    then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = {&cmp}
           and  buf_clients.obj-code = p-host-code no-error .
      do jj = 1 to num-entries(v-hold-ee-code):
        assign
        v-dop = entry(jj, v-hold-ee-code)
        .
  &scop tpsi-doc-kind temp-tpsi-doc.doc-kind
        create temp-tpsi-doc.
        assign
        temp-tpsi-doc.host-code = integer(entry(1, v-dop,  {&space-char}))
        temp-tpsi-doc.obj-type = entry(2, v-dop,  {&space-char})
        temp-tpsi-doc.obj-code = integer(entry(3, v-dop,  {&space-char}))
        temp-tpsi-doc.doc-code   = entry(4, v-dop, {&space-char})
        temp-tpsi-doc.out-code   = p-inkas-code
        temp-tpsi-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
        temp-tpsi-doc.alias-type-price = entry(5, v-dop, {&space-char})
        temp-tpsi-doc.price-obj-type   = entry(6, v-dop, {&space-char})
        temp-tpsi-doc.price-obj-code   = integer(entry(7, v-dop, {&space-char}))
        temp-tpsi-doc.doc-kind  = entry(lookup(temp-tpsi-doc.ext-doc-type, {&tpsi-ext-doc-types}), {&tpsi-doc-kinds})
        temp-tpsi-doc.doc-label = {&tpsi-doc-name-k}
        temp-tpsi-doc.cli-type = {&cmp}
        temp-tpsi-doc.cli-code = p-host-code
        temp-tpsi-doc.cli-name = (if available buf_clients then buf_clients.obj-name else '':U)
        no-error
        .
        if error-status :error then  do:
          undo, return error substitute( "неверный формат значения атрибута документа &1 &2:&3&4 &5"
                                      , p-inkas-code
                                      , {&trdcattr-hold-ee-tpsi-code}
                                      , {&new-line}
                                      , error-status :get-message( 1 )
                                      , return-value
                                      ).
        end.
      end.
    end.
    if v-ev-code <> ?
    and v-ev-code <> "":U then do:
      find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        and  buf_clients.obj-code = p-obj-code no-error .
      do jj = 1 to num-entries(v-ev-code):
        assign
        v-dop = entry(jj, v-ev-code)
        .
        create temp-tpsi-doc.
        assign
        temp-tpsi-doc.host-code = integer(entry(1, v-dop,  {&space-char}))
        temp-tpsi-doc.obj-type = entry(2, v-dop,  {&space-char})
        temp-tpsi-doc.obj-code = integer(entry(3, v-dop,  {&space-char}))
        temp-tpsi-doc.doc-code   = entry(4, v-dop, {&space-char})
        temp-tpsi-doc.out-code   = p-inkas-code
        temp-tpsi-doc.ext-doc-type = {&TDEDT_Ras_Perem}
        temp-tpsi-doc.alias-type-price = entry(5, v-dop, {&space-char})
        temp-tpsi-doc.price-obj-type   = entry(6, v-dop, {&space-char})
        temp-tpsi-doc.price-obj-code   = integer(entry(7, v-dop, {&space-char}))
        temp-tpsi-doc.doc-kind  = entry(lookup(temp-tpsi-doc.ext-doc-type, {&tpsi-ext-doc-types}), {&tpsi-doc-kinds})
        temp-tpsi-doc.doc-label = {&tpsi-doc-name-k}
        temp-tpsi-doc.cli-type =  p-obj-type
        temp-tpsi-doc.cli-code =  p-obj-code
        temp-tpsi-doc.cli-name =  (if available buf_clients then buf_clients.obj-name else '':U)
        no-error
        .
        if error-status :error then do:
          undo, return error substitute( "неверный формат значения атрибута документа &1 &2:&3&4 &5"
                                      , p-inkas-code
                                      , {&trdcattr-ev-tpsi-code}
                                      , {&new-line}
                                      , error-status :get-message( 1 )
                                      , return-value
                                      ) .
        end.
      end.
    end.
    if p-add-from-db then do:
      {&add-from-db}.
    end.
  end.

end procedure. /* ttpsidoc-fill */

procedure rewrite-doc-attr-tpsi :
define input parameter p-inkas-code         like ub.trn-doc.doc-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-add-from-db as logical no-undo .

define variable v-attr-type                 as character no-undo .
define variable v-attr-value                as character no-undo .
define variable v-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define variable v-alias-type-price as character no-undo .
define variable v-price-obj-type like ub.clients.obj-type no-undo .
define variable v-price-obj-code like ub.clients.obj-code no-undo .

define buffer buf_trn-doc for ub.trn-doc.

  do
  on error undo, return error return-value
  :
  /*перезапишем атрибут*/
  if p-add-from-db then do:
    {&add-from-db}.
  end.
  for each temp-tpsi-doc where
         temp-tpsi-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}:
    assign
    v-attr-value = v-attr-value + (if v-attr-value = "":U then "":U else {&comma-char}) +
                   string(temp-tpsi-doc.host-code) + {&space-char}  +
                   temp-tpsi-doc.obj-type + {&space-char}  +
                   string(temp-tpsi-doc.obj-code) + {&space-char}  +
                   temp-tpsi-doc.doc-code + {&space-char} +
                   temp-tpsi-doc.alias-type-price + {&space-char} +
                   temp-tpsi-doc.price-obj-type + {&space-char} +
                   string(temp-tpsi-doc.price-obj-code)
                   .
  end.
  { str/tdat-wrt.i
      p-inkas-code
      {&trdcattr-hold-ee-tpsi-code}
      v-attr-value
      no-error
  }
  if error-status :error then do:
    undo, return error substitute( "Ошибка записи атрибута <Док-ты межфирм. расхода> для закрытия продажи на ТПСИ &3&4&5"
                                 , {&new-line}
                                 , error-status :get-message( 1 )
                                 , return-value
                                 ) .
  end.
  assign
  v-attr-value = "":U.
  for each temp-tpsi-doc where
         temp-tpsi-doc.ext-doc-type = {&TDEDT_Ras_PEREM}:
    assign
    v-attr-value = v-attr-value + (if v-attr-value = "":U then "":U else {&comma-char}) +
                   string(temp-tpsi-doc.host-code) + {&space-char}  +
                   temp-tpsi-doc.obj-type + {&space-char}  +
                   string(temp-tpsi-doc.obj-code) + {&space-char}  +
                   temp-tpsi-doc.doc-code + {&space-char} +
                   temp-tpsi-doc.alias-type-price + {&space-char} +
                   temp-tpsi-doc.price-obj-type + {&space-char} +
                   string(temp-tpsi-doc.price-obj-code)
                   .

  end.
  { str/tdat-wrt.i
      p-inkas-code
      {&trdcattr-ev-tpsi-code}
      v-attr-value
      no-error
  }
  if error-status :error then do:
    undo, return error substitute( "Ошибка записи атрибута <Док-ты внутр. расхода> для закрытия продажи на ТПСИ &3&4&5"
                                 , {&new-line}
                                 , error-status :get-message( 1 )
                                 , return-value
                                 ) .
  end.
  /*КОНЕЦ ОБНОВЛЕНИЯ АТРИБУТОВ*/

  end.

end procedure. /* rewrite-doc-attr-tpsi */

procedure create-tt0-doc-line-gds-dtl :
define input parameter p-proprietor-obj-type like ub.trn-doc.obj-type no-undo .
define input parameter p-proprietor-obj-code like ub.trn-doc.obj-code no-undo .
define input parameter p-ext-doc-type        as character no-undo .
define input parameter p-doc-code            like ub.trn-doc.doc-code no-undo .
define input parameter p-artic               like ub.gds-dtl.artic no-undo .
define input parameter p-prod-type           like ub.gds-dtl.prod-type no-undo .
define input parameter p-prod-code           like ub.gds-dtl.prod-code no-undo .
define input parameter p-prt-code            like ub.gds-dtl.prt-code  no-undo .
define input parameter p-fact-qnty           like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-was-gds-dtl-doc-qnty  like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-gds-dtl-fact-qnty  like ub.gds-dtl.fact-qnty no-undo .
define parameter buffer b-doc-line           for ub.doc-line.
define parameter buffer b-gds-dtl            for ub.gds-dtl.
define parameter buffer buf_temp-tpsi-doc for temp-tpsi-doc.

define variable old-qnty like ub.doc-line.fact-qnty no-undo .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl for ub.gds-dtl.

  do
  on error undo, return error return-value
  :
    find first tt0-doc-line where
              tt0-doc-line.obj-type = p-proprietor-obj-type
          AND tt0-doc-line.obj-code = p-proprietor-obj-code
          AND tt0-doc-line.prod-type = p-prod-type
          AND tt0-doc-line.prod-code = p-prod-code
          AND tt0-doc-line.artic     = p-artic
          AND tt0-doc-line.ext-doc-type = p-ext-doc-type
          AND tt0-doc-line.status_      = {&doc-froze} no-error .
    if not available tt0-doc-line then do:
      create tt0-doc-line.
      buffer-copy b-doc-line
      except
      obj-type obj-code doc-code status_ ext-doc-type doc-qnty fact-qnty
      to tt0-doc-line
      assign
      tt0-doc-line.status_ = {&doc-froze}
      tt0-doc-line.ext-doc-type = p-ext-doc-type
      tt0-doc-line.obj-type = p-proprietor-obj-type
      tt0-doc-line.obj-code = p-proprietor-obj-code
      tt0-doc-line.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
      /*а посмотрим сколько для нас там зарезервировано*/
      find first other_doc-line no-lock where
              other_doc-line.doc-code = p-doc-code
          AND  other_doc-line.artic    = p-artic
          AND  other_doc-line.prod-type = p-prod-type
          AND  other_doc-line.prod-code = p-prod-code no-error .
      if available other_doc-line then do:
        find first buf_temp-tpsi-doc where buf_temp-tpsi-doc.doc-code = other_doc-line.doc-code.
        assign
        tt0-doc-line.doc-qnty = other_doc-line.doc-qnty
        .
      end.
      else do:
        assign
        tt0-doc-line.doc-code = '':U
        .
      end.
    end. /*if p-doc-code <> "":U then do:*/
    find first tt0-gds-dtl where
            tt0-gds-dtl.obj-type = p-proprietor-obj-type
        AND tt0-gds-dtl.obj-code = p-proprietor-obj-code
        AND tt0-gds-dtl.prod-type = p-prod-type
        AND tt0-gds-dtl.prod-code = p-prod-code
        AND tt0-gds-dtl.artic     = p-artic
        AND tt0-gds-dtl.prt-code  = p-prt-code  no-error .
    if not available tt0-gds-dtl then do:
      create tt0-gds-dtl.
      buffer-copy b-gds-dtl
      except
      obj-type obj-code doc-code doc-qnty fact-qnty
      to tt0-gds-dtl
      assign
      tt0-gds-dtl.obj-type = p-proprietor-obj-type
      tt0-gds-dtl.obj-code = p-proprietor-obj-code
      tt0-gds-dtl.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
        /*а посмотрим сколько для нас там зарезервировано*/
        find first other_gds-dtl no-lock where
                other_gds-dtl.doc-code = p-doc-code
            AND  other_gds-dtl.artic    = p-artic
            AND  other_gds-dtl.prod-type    = p-prod-type
            AND  other_gds-dtl.prod-code    = p-prod-code
            AND  other_gds-dtl.prt-code    = p-prt-code no-error .
        if available other_gds-dtl then do:
          assign
          tt0-gds-dtl.doc-qnty = other_gds-dtl.doc-qnty
          .
        end.
        else do:
          assign
          tt0-gds-dtl.doc-code = '':U
          .
        end.
    end. /*if p-doc-code <> "":U then do:*/
    assign
    /*пишем СКОЛЬКО ЕЩЕ ХОТИМ!!!!! потом что при копировании добавляет*/
    old-qnty = tt0-gds-dtl.doc-qnty
    tt0-gds-dtl.fact-qnty = (if p-fact-qnty = ? then (- old-qnty) else (p-fact-qnty - tt0-gds-dtl.doc-qnty))
    tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty + (if p-fact-qnty = ? then (- old-qnty) else p-fact-qnty)
    p-gds-dtl-fact-qnty = tt0-gds-dtl.fact-qnty
    p-was-gds-dtl-doc-qnty = tt0-gds-dtl.doc-qnty
    .
  end. /*doe*/

end procedure. /* create-tt0-doc-line-gds-dtl */

procedure fill-tt-tpsi-table :
define input parameter p-doc-code  like ub.trn-doc.doc-code  no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code  no-undo .

define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-fact-qnty     like ub.gds-dtl.fact-qnty no-undo .


define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_temp-tpsi-doc for temp-tpsi-doc.

  do
  on error undo, return error
  :
    _doc-line:
    for each buf_Doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code,
      first buf_goods no-lock where
          buf_goods.artic = buf_doc-line.artic
     AND  buf_goods.prod-type  = buf_doc-line.prod-type
     AND  buf_goods.prod-code  = buf_doc-line.prod-code,
        each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_doc-line.doc-code
      AND  buf_gds-dtl.artic    = buf_doc-line.artic
      AND  buf_gds-dtl.prod-type = buf_doc-line.prod-type
      AND  buf_gds-dtl.prod-code = buf_doc-line.prod-code:
      assign
      v-ext-doc-type = "":U.
      run tpsi-preselect-gds-proprietor in this-procedure (
                                                  input buf_goods.gds-code
                                                ,input g#db-num
                                                ,output v-proprietor-host-code
                                                ,output v-proprietor-obj-type
                                                ,output v-proprietor-obj-code ) no-error .
      if v-proprietor-host-code = p-host-code then do:
        assign
        v-ext-doc-type = {&TDEDT_Ras_Perem} .
      end.
      else do:
        assign
        v-ext-doc-type =  {&TDEDT_Ras_Vnesh} .
      end.
      if  (v-proprietor-obj-type = p-obj-type
      AND v-proprietor-obj-code = p-obj-code)
      OR (v-proprietor-obj-type = "":U
      AND v-proprietor-obj-code = 0) then next _doc-line.
      find first buf_temp-tpsi-doc no-lock where
                buf_temp-tpsi-doc.obj-type = v-proprietor-obj-type
           AND  buf_temp-tpsi-doc.obj-code = v-proprietor-obj-code
           AND  buf_temp-tpsi-doc.ext-doc-type = v-ext-doc-type
           no-error .

      run create-tt0-doc-line-gds-dtl  in this-procedure (
                                                           input v-proprietor-obj-type
                                                          ,input v-proprietor-obj-code
                                                          ,input v-ext-doc-type
                                                          ,input (if available buf_temp-tpsi-doc then buf_temp-tpsi-doc.doc-code else "":U)
                                                          ,input buf_doc-line.artic
                                                          ,input buf_Doc-line.prod-type
                                                          ,input buf_doc-line.prod-code
                                                          ,input buf_gds-dtl.prt-code
                                                          ,input 0
                                                          ,output v-was-gds-dtl-fact-qnty
                                                          ,output v-gds-dtl-fact-qnty
                                                          ,buffer buf_doc-line
                                                          ,buffer buf_gds-dtl
                                                          ,buffer buf_temp-tpsi-doc
                                                        ).
    end.
  end.
end procedure. /* fill-tt-table */


procedure get-alias-type-price-obj :
/*получение типа цены перемещения и объекта для взятия цены для пары ОБЪЕКТ ПРОДАЖИ - ОБЪЕКТ ПЕРЕМЕЩЕНИЯ*/
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-prop-host-code like ub.sysconf.host-code no-undo .
define input parameter p-prop-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-prop-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define output parameter p-alias-type-price as character no-undo .
define output parameter p-price-obj-type like ub.clients.obj-type no-undo .
define output parameter p-price-obj-code like ub.clients.obj-code no-undo .

define variable v-mediat-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-mediat-obj-code           like ub.trn-doc.obj-code no-undo .
define variable v-mediat-objf               as character no-undo .
define variable v-attr-type as character no-undo .
define buffer buf_trn-doc for ub.trn-doc.
  _main:
  do
  on error undo, return error return-value
  :
    run clntattr-value in this-procedure (
                                            input  p-prop-obj-type
                                          , input  p-prop-obj-code
                                          , input  {&attr-alias-type-price}
                                          , output p-alias-type-price
                                          , output v-attr-type
                                              ).
    if error-status:error
    or (p-alias-type-price = "":U
        and
        p-prop-host-code <> p-host-code)
    then do:
      undo _main, return error substitute("Не задано значение атрибута ТИП ЦЕНЫ МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.

    if p-prop-host-code = p-host-code
    and (p-alias-type-price = '':U
    or   p-alias-type-price <> {&alias-type-price-sale-doc})
    then  do:
      assign
      p-ext-doc-type = {&TDEDT_Ras_Perem}
      p-price-obj-type = p-obj-type
      p-price-obj-code = p-obj-code
      p-alias-type-price = {&alias-type-price-crsa-r}
      .
    end. /*конец блока внутреннего РАСХОДА ПО УМОЛЧАНИЮ*/
    else do:
      if p-prop-host-code = p-host-code  then do:
        assign
        p-ext-doc-type = {&TDEDT_Ras_Perem}
        p-price-obj-type = p-obj-type
        p-price-obj-code = p-obj-code
        .
      end.
      else do:
        assign
        p-ext-doc-type = {&TDEDT_Ras_Vnesh}.
        /*найдем тип цены межфирменного перемещения*/
        assign
        v-mediat-obj-type = "":U
        v-mediat-obj-code = 0
        v-mediat-objf = "":U
        .

        if p-alias-type-price = {&alias-type-price-m} then do:
          run clntattr-value in this-procedure (
                                              input  p-prop-obj-type
                                              , input  p-prop-obj-code
                                              , input  {&attr-alias-object-price}
                                              , output v-mediat-objf
                                              , output v-attr-type
                                                  ) no-error .
          if error-status:error
          or v-mediat-objf = "":U then do:
            undo _main, return error substitute("Не найден объект-посредник для межфирменного перемещения ЧУЖИХ товаров с &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end. /* if error-status:error or v-mediat-objf = "":U then do:*/
          assign
          v-mediat-obj-type = entry(1, v-mediat-objf)
          v-mediat-obj-code = integer(entry(2, v-mediat-objf))
          no-error
          .
          if error-status:error then do:
            undo _main, return error substitute("Неверный формат атрибута ОБЪЕКТ-ПОСРЕДНИК для межфирменного перемещения ЧУЖИХ товаров для &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
        end. /*if p-alias-type-price = {&alias-type-price-m} then do:*/
        CASE p-alias-type-price:
          when {&alias-type-price-cost} then do:
            /*учетная*/
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
            /*делаем после вызова lib-trn_copy-ret */
          end.
          when {&alias-type-price-crsa-p} then do:
            /*продажная поставщика - объект чей товар*/
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when {&alias-type-price-crsa-r}
          or
          when {&alias-type-price-sale-doc}
          then do:
            /*продажная приемника - цена нашего объекта*/
            assign
            p-price-obj-type = p-obj-type
            p-price-obj-code = p-obj-code
            .
          end.
          when {&alias-type-price-m} then do:
            /*продажная посредника - цена объекта посредника*/
            assign
            p-price-obj-type = v-mediat-obj-type
            p-price-obj-code = v-mediat-obj-code
            .
          end.
        END CASE.
      end. /*конец блока межфирмы */
    end. /*конец  блока с заданием параметра */
  end. /*doe*/

end procedure. /* get-alias-type-price-obj */

procedure write-tt0-info:
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define input parameter p-prt-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-from-tpsi as logical no-undo .
define input parameter p-all-qnty as decimal no-undo .
define input parameter p-was-res as decimal no-undo .
define input parameter p-to-res as decimal no-undo .
define input parameter p-is-res as decimal no-undo .
define input parameter p-o-was-res as decimal no-undo .
define input parameter p-o-to-res as decimal no-undo .
define input parameter p-o-is-res as decimal no-undo .
define input parameter p-mess   as character no-undo .
define buffer buf_tt0-info for tt0-info.

  do
  on error undo, return error return-value
  :
    find first buf_tt0-info where
             buf_tt0-info.artic = p-artic
         and buf_tt0-info.prod-type = p-prod-type
         and buf_tt0-info.prod-code = p-prod-code
         and buf_tt0-info.prt-code = p-prt-code
         no-error .
    if not available buf_tt0-info then do:
      create buf_tt0-info.
      assign
      buf_tt0-info.artic = p-artic
      buf_tt0-info.prod-type = p-prod-type
      buf_tt0-info.prod-code = p-prod-code
      buf_tt0-info.prt-code  = p-prt-code
      buf_tt0-info.obj-type  = p-obj-type
      buf_tt0-info.obj-code  = p-obj-code
      buf_tt0-info.a-to-res  = ?
      buf_tt0-info.to-res    = ?
      buf_tt0-info.was-res   = ?
      buf_tt0-info.o-was-res = ?
      buf_tt0-info.o-to-res  = ?
      buf_tt0-info.o-is-res  = ?
      buf_tt0-info.is-res    = ?
      .

    end.
    assign
    buf_tt0-info.a-to-res  =
                              (if buf_tt0-info.a-to-res <> ?
                              and p-all-qnty = ?
                              then buf_tt0-info.a-to-res
                              else p-all-qnty)
    buf_tt0-info.was-res   = (if buf_tt0-info.was-res <> ?
                              and p-was-res = ?
                              then buf_tt0-info.was-res
                              else p-was-res)
    buf_tt0-info.to-res    = (if buf_tt0-info.to-res <> ?
                              and p-to-res = ?
                              then buf_tt0-info.to-res
                              else p-to-res)
    buf_tt0-info.is-res    = (if buf_tt0-info.is-res <> ?
                              and p-is-res = ?
                              then buf_tt0-info.is-res
                              else p-is-res)
    buf_tt0-info.o-was-res   = (if buf_tt0-info.o-was-res <> ?
                              and p-o-was-res = ?
                              then buf_tt0-info.o-was-res
                              else p-o-was-res)
    buf_tt0-info.o-to-res    = (if buf_tt0-info.o-to-res <> ?
                              and p-o-to-res = ?
                              then buf_tt0-info.o-to-res
                              else p-o-to-res)
    buf_tt0-info.o-is-res    = (if buf_tt0-info.o-is-res <> ?
                              and p-o-is-res = ?
                              then buf_tt0-info.o-is-res
                              else p-o-is-res)
    .
    assign
    buf_tt0-info.doc-code  = p-doc-code
    buf_tt0-info.error-message   = p-mess
    .
  end.
end procedure. /* write-tt0-info: */


&endif

/* $Workfile$ e n d */