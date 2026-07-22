block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-cstvz.p $
$Archive: rep/r-cstvz.p $

ОТЧЕТ Документы возврата в разрезе накладных поставщика и ГТД

Автор: Чернова Светлана Александровна
Дата создания: 07/07/09
Author: Svetlana Chernova
Creation date: 07/07/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cstvz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-cstvz.p $":U .
define variable vss-description as character no-undo init "Документы возврата в разрезе накладных поставщика и ГТД".
{ cmp/vssrevis.i  }

{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i    }
{ cmp/r-page1.i    }
{ gbl/cur-time.i   }
{ gbl/waitfram.i   }
{ str/trdcalib.i   }

define variable sheets       as integer   no-undo .
define variable Line         as character no-undo .
define variable g#report-num as integer   no-undo .
define variable varline-num  as integer   no-undo .
define variable v-curr-r-b   as character no-undo .

define temp-table tt-gds-parts no-undo
field out-code    like ub.trn-doc.out-code
field doc-code    like ub.trn-doc.doc-code
field in-code     like ub.trn-doc.doc-code
field obj-code    like ub.trn-doc.obj-code
field obj-type    like ub.trn-doc.obj-type
field date-trn    like ub.trn-doc.doc-date
field gds-code    like ub.goods.gds-code
field artic       like ub.goods.artic
field prod-type   like ub.goods.prod-type
field prod-code   like ub.goods.prod-code
field part-code   like ub.parts.part-code
field gds-name    like ub.goods.gds-name
field prod-name   like ub.clients.obj-name
field doc-qnty    like ub.doc-line.doc-qnty initial 0.00
field price       like ub.doc-line.price-base
field sum-brutto  as decimal format "->,>>>,>>>,>>9.99"
field num-doc     as character
field date-doc    as date
field cst-code    like ub.parts.cst-code
field line-num    as integer
index pi is unique primary
      line-num
index print-order
      doc-code gds-code line-num
.

define variable varsum-qnty   like tt-gds-parts.doc-qnty   initial 0.00 no-undo.
define variable varsum-brutto like tt-gds-parts.sum-brutto no-undo.
{ gbl/curr-r-b.i v-curr-r-b }
run prn-lib-open-stream  in this-procedure
 ( input my-handle
  ,input {&CS_PS}
  ,input yes /* p-is-stream */
  ,input no  /* p-append    */
  ) .

/*заполним временные таблицы*/
run fill-tt in this-procedure.
run waitfram-show in this-procedure ( {&MyWaitMess} ) .
FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
sheetf.sizes = "".
assign
  Sheetf.Excel-Column-Lable =
    "Номер документа"            + {&comma-char} +
    "Дата документа"             + {&comma-char} +
    "Код"                        + {&comma-char} +
    "Артикул"                    + {&comma-char} +
    "Название"                   + {&comma-char} +
    "Производитель"              + {&comma-char} +
    "Кол-во"                     + {&comma-char} +
    "Цена"                       + {&comma-char} +
    "Сумма"                      + {&comma-char} +
    "Номер документа поставщика" + {&comma-char} +
    "Дата документа поставщика"  + {&comma-char} +
    "ГТД"
  Sheetf.Sizes     =   "9,11,16,16,30,20,17,17,17,20,11,32"
  sheetf.colformat =   "1=@;2=dd/mm/yy;11=dd/mm/yy;12=@":U
  .

  run rep/extitle.p (1) no-error.

  for each tt-gds-parts use-index print-order:
    {&PutExcel}
    tt-gds-parts.doc-code    {&tabulation}
    string ( tt-gds-parts.date-trn , "99/99/9999") {&tabulation}
    tt-gds-parts.gds-code    {&tabulation}
    tt-gds-parts.artic       {&tabulation}
    tt-gds-parts.gds-name    {&tabulation}
    tt-gds-parts.prod-name   {&tabulation}
    tt-gds-parts.doc-qnty    {&tabulation}
    string(tt-gds-parts.price,">>>>>>>>>>9.99" )       {&tabulation}
    string(tt-gds-parts.sum-brutto,">>>>>>>>>>9.99" )  {&tabulation}
    tt-gds-parts.num-doc     {&tabulation}
    if tt-gds-parts.date-doc  = ? then "" else string(tt-gds-parts.date-doc, "99/99/9999" )  {&tabulation}
    tt-gds-parts.cst-code    {&tabulation}
    skip.

    assign
      varsum-qnty   = varsum-qnty   + tt-gds-parts.doc-qnty
      varsum-brutto = varsum-brutto + tt-gds-parts.sum-brutto
      .
  end.
  {&PutExcel}
  "Итого"        {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  varsum-qnty    {&tabulation}
  ""             {&tabulation}
  string(varsum-brutto,">>>>>>>>>>9.99" )  {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  skip.
output stream prnlibstream close .
{&closeExcel}


run waitfram-hide  in this-procedure .
run get-report-num in my-handle (output g#report-num) .
run rep/runexcel.p ( string(session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt" ) .


procedure fill-tt:
define buffer bf_trn-doc              for ub.trn-doc.
define buffer bf_doc-line             for ub.doc-line.
define buffer bf-exp_trn-doc          for ub.trn-doc.
define buffer bf-exp_parts            for ub.parts.
define buffer bf_goods                for ub.goods.
define buffer bf_clients              for ub.clients.
define buffer bf-in_trn-doc           for ub.trn-doc.
define buffer buf_parts-attr          for ub.parts-attr  .
define buffer buf_parts-root          for ub.parts-root  .

define variable v-attr-value-nids as character no-undo.
define variable v-attr-value-dids as character no-undo.
define variable v-attr-type       as character no-undo.
define variable v-part-code       like ub.parts.part-code  no-undo .
define variable v-in-code         like ub.parts.in-code    no-undo .
define variable v-gds-code        like ub.parts-attr.gds-code    no-undo .


for each tt-gds-parts :
  delete tt-gds-parts.
end.

for each obj-list :
   run waitfram-show in this-procedure ( substitute("Сбор данных на объекте &2&1" , obj-list.obj-code  , obj-list.obj-type)) .
  _trn-doc:
    for each bf_trn-doc where
        bf_trn-doc.obj-type =  obj-list.obj-type and
        bf_trn-doc.obj-code =  obj-list.obj-code and
        bf_trn-doc.status_      = {&fact} and
        bf_trn-doc.internal     = false  and
        bf_trn-doc.doc-type     = {&expense}  and
        bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and
        bf_trn-doc.fact-order >= integer(x-date-start) and
        bf_trn-doc.fact-date >= x-date-start      and
        bf_trn-doc.fact-date <= x-date-end        no-lock :
    for each bf_doc-line where
             bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock :
       find first bf_goods    where
                  bf_goods.artic      = bf_doc-line.artic     and
                  bf_goods.prod-type  = bf_doc-line.prod-type and
                  bf_goods.prod-code  = bf_doc-line.prod-code
                  no-lock.
       find first bf_clients  where bf_clients.obj-type = bf_goods.prod-type and
                                    bf_clients.obj-code = bf_goods.prod-code no-lock .
        for each bf-exp_parts where
                 bf-exp_parts.artic     = bf_doc-line.artic    and
                 bf-exp_parts.prod-type = bf_doc-line.prod-type  and
                 bf-exp_parts.prod-code = bf_doc-line.prod-code  and
                 bf-exp_parts.out-code  = bf_trn-doc.doc-code
                 no-lock :
          varline-num = varline-num + 1.
          create tt-gds-parts.
          buffer-copy bf-exp_parts to tt-gds-parts
          assign
           tt-gds-parts.date-trn  =  bf_trn-doc.fact-date
           tt-gds-parts.line-num  =  varline-num
           tt-gds-parts.doc-code  =  bf_trn-doc.doc-code
           tt-gds-parts.gds-code  =  bf_goods.gds-code
           tt-gds-parts.obj-type  =  bf_trn-doc.obj-type
           tt-gds-parts.obj-code  =  bf_trn-doc.obj-code
           tt-gds-parts.artic     =  bf_goods.artic
           tt-gds-parts.prod-type =  bf_goods.prod-type
           tt-gds-parts.prod-code =  bf_goods.prod-code
           tt-gds-parts.gds-name  =  bf_goods.gds-name
           tt-gds-parts.prod-name =  bf_clients.obj-name
           tt-gds-parts.price      = if x-SET_val_TYPE = {&v-rubl} then bf-exp_parts.price-rubl else bf-exp_parts.price-base
           tt-gds-parts.doc-qnty   = bf-exp_parts.qnty
           tt-gds-parts.sum-brutto = tt-gds-parts.doc-qnty * tt-gds-parts.price
          .
          assign
            v-attr-value-nids = ""
            v-attr-value-dids = ""
            v-attr-type       = ""
            .

      find first buf_parts-root no-lock
          where buf_parts-root.part-code = tt-gds-parts.part-code and
                buf_parts-root.in-code   = tt-gds-parts.in-code   and
                buf_parts-root.gds-code  = tt-gds-parts.gds-code  no-error .
     if available buf_parts-root then do:
      assign
          v-part-code  = buf_parts-root.orig-part-code
          v-in-code    = buf_parts-root.orig-in-code
          v-gds-code   = buf_parts-root.orig-gds-code
      .
     end.
     else do:
        assign
          v-part-code = tt-gds-parts.part-code
          v-in-code   = tt-gds-parts.in-code
          v-gds-code  = tt-gds-parts.gds-code
        .
     end.


      find first buf_parts-attr no-lock
          where buf_parts-attr.part-code = v-part-code  and
                buf_parts-attr.in-code   = v-in-code    and
                buf_parts-attr.gds-code  = v-gds-code   no-error .

          find first bf-in_trn-doc where
                     bf-in_trn-doc.doc-code = buf_parts-attr.income-in-code
                     no-lock no-error.
          if available bf-in_trn-doc then do:
            { str/tdat-val.i
              bf-in_trn-doc.doc-code
              {&trdcattr-nids}
              v-attr-value-nids
              v-attr-type
            }
            { str/tdat-val.i
              bf-in_trn-doc.doc-code
              {&trdcattr-dids}
              v-attr-value-dids
              v-attr-type
            }
              if tt-gds-parts.cst-code = ""  then do:
                 tt-gds-parts.cst-code = buf_parts-attr.cst-code .
              end.

          end.
          assign
            tt-gds-parts.num-doc  = ( if available bf-in_trn-doc then v-attr-value-nids else "Нет ВПН"  )
            tt-gds-parts.date-doc = ( if available bf-in_trn-doc then DATE(v-attr-value-dids) else ?    )
          .
        end.
       end.
    end.
  end.
end procedure.