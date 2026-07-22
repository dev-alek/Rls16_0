block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-hist.p $
$Archive: str/trn-hist.p $

Запись истории по документу

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06


*/

define parameter buffer p-bf_trn-doc for ub.trn-doc .
define input  parameter p-curr-obj-type as character no-undo .
define input  parameter p-curr-obj-code as integer   no-undo .
define input  parameter p-action as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: trn-hist.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/trn-hist.p $":U .
define variable vss-description as character no-undo initial "Запись истории по документу":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ trg/checkart.i }

define variable j-chip-num as integer no-undo .
define buffer bf_goods         for ub.goods         .




define variable l-shift-on as logical no-undo .
define variable p-shift-date as date      no-undo initial ? .
define variable p-shift-num  as integer   no-undo initial 0 .
define variable p-shift-name as character no-undo initial ? .
define variable v-today as date      no-undo .
define variable v-time  as integer   no-undo .
define variable v-result-field as character no-undo .
Main-Block:
do
transaction
on error   undo Main-Block, return error return-value
on end-key undo Main-Block, return error return-value
on stop    undo Main-Block, return error return-value
:
  /* if g#news = yes then do: return. end. */
  assign
    j-chip-num = next-value( s-corr-chip, {&db-name_schema} )
  .
  find first ub.c-trn-doc no-lock where
             ub.c-trn-doc.doc-code         = p-bf_trn-doc.doc-code and
             ub.c-trn-doc.corr-user-db-num = g#db-num and
             ub.c-trn-doc.chip-num         = j-chip-num
             no-error .
  if not available ub.c-trn-doc
  then do:
    create ub.c-trn-doc .
    buffer-copy p-bf_trn-doc to ub.c-trn-doc no-error .
    if error-status :error
    then do:
      undo Main-Block, return error .
    end.

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  { gbl/objat.i
    p-curr-obj-type
    p-curr-obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on = true then do:
    /* на объекте включены смены */
    { gbl/curshift.i
      p-curr-obj-type
      p-curr-obj-code
      p-shift-date
      p-shift-num
      p-shift-name
      no-error
    }
    end.
    assign
      ub.c-trn-doc.chip-num  = j-chip-num
      ub.c-trn-doc.corr-date = v-today
      ub.c-trn-doc.corr-time = v-time
      ub.c-trn-doc.corr-user-name  = g#userid
      ub.c-trn-doc.corr-user-db-num = g#db-num
      ub.c-trn-doc.action = p-action
      ub.c-trn-doc.corr-shift-date = p-shift-date
      ub.c-trn-doc.corr-shift-name = p-shift-name
      ub.c-trn-doc.corr-shift-num  = p-shift-num
      .
  end.


define buffer bf_trn-doc-sum    for ub.trn-doc-sum   .
define buffer old_c-trn-doc-sum for ub.c-trn-doc-sum  .
  for each bf_trn-doc-sum no-lock where
           bf_trn-doc-sum.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-trn-doc-sum no-lock where
               old_c-trn-doc-sum.doc-code = bf_trn-doc-sum.doc-code and
               old_c-trn-doc-sum.corr-user-db-num = g#db-num and
               old_c-trn-doc-sum.sum-type = bf_trn-doc-sum.sum-type  and
               old_c-trn-doc-sum.chip-num <= j-chip-num
               no-error .
    if available old_c-trn-doc-sum then do:
        v-result-field = "" .

        buffer-compare ub.c-trn-doc-sum
          except chip-num
                 corr-date
                 corr-time
                 corr-user-db-num
                 corr-user-name
          to  bf_trn-doc-sum
          save result in v-result-field no-error  .

    end.
    if not available old_c-trn-doc-sum  or v-result-field <> ""
    then do:
      create ub.c-trn-doc-sum .
      buffer-copy bf_trn-doc-sum to ub.c-trn-doc-sum .
      assign
        ub.c-trn-doc-sum.chip-num         = j-chip-num
        ub.c-trn-doc-sum.corr-user-db-num = g#db-num
        .
    end.
  end.



define buffer bf_doc-line    for ub.doc-line    .
define buffer old_c-doc-line for ub.c-doc-line  .

  for each bf_doc-line no-lock where
           bf_doc-line.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-line no-lock where
               old_c-doc-line.doc-code         = bf_doc-line.doc-code   and
               old_c-doc-line.artic            = bf_doc-line.artic      and
               old_c-doc-line.prod-type        = bf_doc-line.prod-type  and
               old_c-doc-line.prod-code        = bf_doc-line.prod-code  and
               old_c-doc-line.corr-user-db-num = g#db-num               and
               old_c-doc-line.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-line then do:
        v-result-field = "" .

        buffer-compare ub.c-doc-line
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-line
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-line  or v-result-field <> ""
    then do:
      create ub.c-doc-line .
      buffer-copy bf_doc-line to ub.c-doc-line .
      assign
        ub.c-doc-line.chip-num         = j-chip-num
        ub.c-doc-line.corr-user-db-num = g#db-num
        .
    end.
  end.
 /*bf_inv-line*/

define buffer bf_inv-line    for ub.inv-line    .
define buffer old_c-inv-line for ub.c-inv-line  .

  for each bf_inv-line no-lock where
           bf_inv-line.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-inv-line no-lock where
               old_c-inv-line.doc-code         = bf_inv-line.doc-code   and
               old_c-inv-line.artic            = bf_inv-line.artic      and
               old_c-inv-line.prod-type        = bf_inv-line.prod-type  and
               old_c-inv-line.prod-code        = bf_inv-line.prod-code  and
               old_c-inv-line.corr-user-db-num = g#db-num               and
               old_c-inv-line.chip-num        <= j-chip-num
               no-error .
    if available old_c-inv-line then do:
        v-result-field = "" .

        buffer-compare ub.c-inv-line
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_inv-line
          save result in v-result-field no-error  .
    end.
    if not available old_c-inv-line  or v-result-field <> ""
    then do:
      create ub.c-inv-line .
      buffer-copy bf_inv-line to ub.c-inv-line .
      assign
        ub.c-inv-line.chip-num         = j-chip-num
        ub.c-inv-line.corr-user-db-num = g#db-num
        .
    end.
  end.

define buffer bf_gds-dtl       for ub.gds-dtl       .
define buffer old_c-gds-dtl for ub.c-gds-dtl  .

  for each bf_gds-dtl no-lock where
           bf_gds-dtl.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-gds-dtl no-lock where
               old_c-gds-dtl.doc-code         = bf_gds-dtl.doc-code   and
               old_c-gds-dtl.artic            = bf_gds-dtl.artic      and
               old_c-gds-dtl.prod-type        = bf_gds-dtl.prod-type  and
               old_c-gds-dtl.prod-code        = bf_gds-dtl.prod-code  and
               old_c-gds-dtl.prt-code         = bf_gds-dtl.prt-code   and
               old_c-gds-dtl.corr-user-db-num = g#db-num              and
               old_c-gds-dtl.chip-num        <= j-chip-num
               no-error .
    if available old_c-gds-dtl then do:
        v-result-field = "" .

        buffer-compare ub.c-gds-dtl
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_gds-dtl
          save result in v-result-field no-error  .
    end.
    if not available old_c-gds-dtl  or v-result-field <> ""
    then do:
      create ub.c-gds-dtl .
      buffer-copy bf_gds-dtl to ub.c-gds-dtl .
      assign
        ub.c-gds-dtl.chip-num         = j-chip-num
        ub.c-gds-dtl.corr-user-db-num = g#db-num
        .
    end.
  end.

define buffer bf_parts         for ub.parts         .
define buffer old_c-parts for ub.c-parts  .
define buffer bf_parts-attr    for ub.parts-attr    .
define buffer old_c-parts-attr for ub.c-parts-attr  .

  for each bf_parts no-lock where
           bf_parts.out-code = p-bf_trn-doc.doc-code
  :
  find first bf_goods no-lock where
             bf_goods.artic     = bf_parts.artic and
             bf_goods.prod-type = bf_parts.prod-type and
             bf_goods.prod-code = bf_parts.prod-code no-error .
    find last  old_c-parts no-lock where
               old_c-parts.out-code         = bf_parts.out-code   and
               old_c-parts.corr-user-db-num = g#db-num              and
               old_c-parts.chip-num        <= j-chip-num
               no-error .
    if available old_c-parts then do:
        v-result-field = "" .

        buffer-compare ub.c-parts
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_parts
          save result in v-result-field no-error  .
    end.
    if not available old_c-parts  or v-result-field <> ""
    then do:
      create ub.c-parts .
      buffer-copy bf_parts to ub.c-parts .
      assign
        ub.c-parts.chip-num         = j-chip-num
        ub.c-parts.corr-user-db-num = g#db-num
        .
    end.
        if available bf_goods then do:
              for each bf_parts-attr no-lock where
                      bf_parts-attr.in-code   = bf_parts.in-code and
                      bf_parts-attr.part-code = bf_parts.part-code and
                      bf_parts-attr.gds-code  = bf_goods.gds-code
              :
                find last  old_c-parts-attr no-lock where
                          old_c-parts-attr.in-code           = bf_parts-attr.in-code   and
                          old_c-parts-attr.part-code         = bf_parts-attr.part-code and
                          old_c-parts-attr.gds-code          = bf_parts-attr.gds-code  and
                          old_c-parts-attr.corr-user-db-num  = g#db-num                and
                          old_c-parts-attr.chip-num         <= j-chip-num
                          no-error .
                if available old_c-parts-attr then do:
                    v-result-field = "" .

                    buffer-compare ub.c-parts-attr
                      except chip-num
                            corr-date
                            corr-time
                            corr-user-name
                            corr-user-db-num
                      to  bf_parts-attr
                      save result in v-result-field no-error  .
                end.
                if not available old_c-parts-attr  or v-result-field <> ""
                then do:
                  create ub.c-parts-attr .
                  buffer-copy bf_parts-attr to ub.c-parts-attr .
                  assign
                    ub.c-parts-attr.chip-num         = j-chip-num
                    ub.c-parts-attr.corr-user-db-num = g#db-num
                    .
                end.
              end.
        end.
  end.
define buffer bf_doc-pl    for ub.doc-pl    .
define buffer old_c-doc-pl for ub.c-doc-pl  .

  for each bf_doc-pl no-lock where
           bf_doc-pl.out-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-pl no-lock where
               old_c-doc-pl.out-code         = bf_doc-pl.out-code and
               old_c-doc-pl.pl-code          = bf_doc-pl.pl-code  and
               old_c-doc-pl.obj-type         = bf_doc-pl.obj-type and
               old_c-doc-pl.obj-code         = bf_doc-pl.obj-code and
               old_c-doc-pl.gds-code         = bf_doc-pl.gds-code and
               old_c-doc-pl.corr-user-db-num = g#db-num           and
               old_c-doc-pl.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-pl then do:
        v-result-field = "" .

        buffer-compare ub.c-doc-pl
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-pl
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-pl  or v-result-field <> ""
    then do:
      create ub.c-doc-pl .
      buffer-copy bf_doc-pl to ub.c-doc-pl .
      assign
        ub.c-doc-pl.chip-num         = j-chip-num
        ub.c-doc-pl.corr-user-db-num = g#db-num
        .
    end.
  end.

define buffer bf_doc-pl-pump   for ub.doc-pl-pump   .
define buffer old_c-doc-pl-pump for ub.c-doc-pl-pump  .

  for each bf_doc-pl-pump no-lock where
           bf_doc-pl-pump.out-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-pl-pump no-lock where
               old_c-doc-pl-pump.out-code         = bf_doc-pl-pump.out-code and
               old_c-doc-pl-pump.pump-code        = bf_doc-pl-pump.pump-code  and
               old_c-doc-pl-pump.pl-code          = bf_doc-pl-pump.pl-code  and
               old_c-doc-pl-pump.obj-type         = bf_doc-pl-pump.obj-type and
               old_c-doc-pl-pump.obj-code         = bf_doc-pl-pump.obj-code and
               old_c-doc-pl-pump.gds-code         = bf_doc-pl-pump.gds-code and
               old_c-doc-pl-pump.corr-user-db-num = g#db-num           and
               old_c-doc-pl-pump.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-pl-pump then do:
        v-result-field = "" .

        buffer-compare ub.c-doc-pl-pump
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-pl-pump
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-pl-pump  or v-result-field <> ""
    then do:
      create ub.c-doc-pl-pump .
      buffer-copy bf_doc-pl-pump to ub.c-doc-pl-pump .
      assign
        ub.c-doc-pl-pump.chip-num         = j-chip-num
        ub.c-doc-pl-pump.corr-user-db-num = g#db-num
        .
    end.
  end.

define buffer bf_rvs-doc          for ub.rvs-doc .
define buffer old_c-rvs-doc       for ub.c-rvs-doc .
define buffer bf_rvs-line         for ub.rvs-line .
define buffer old_c-rvs-line      for ub.c-rvs-line .
define buffer bf_rvs-line-pump    for ub.rvs-line-pump .
define buffer old_c-rvs-line-pump for ub.c-rvs-line-pump  .

  for each bf_rvs-doc no-lock where
           bf_rvs-doc.out-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-rvs-doc no-lock where
               old_c-rvs-doc.rvs-code         = bf_rvs-doc.rvs-code and
               old_c-rvs-doc.corr-user-db-num = g#db-num           and
               old_c-rvs-doc.chip-num        <= j-chip-num
               no-error .
    if available old_c-rvs-doc then do:
        v-result-field = "" .

        buffer-compare ub.c-rvs-doc
          except chip-num
                 corr-date
                 corr-time
                 out-code
                 corr-user-name
                 corr-user-db-num
          to  bf_rvs-doc
          save result in v-result-field no-error  .
    end.
    if not available old_c-rvs-doc  or v-result-field <> ""
    then do:
      create ub.c-rvs-doc .
      buffer-copy bf_rvs-doc to ub.c-rvs-doc .
      assign
        ub.c-rvs-doc.chip-num         = j-chip-num
        ub.c-rvs-doc.corr-user-db-num = g#db-num
        .
    end.
          for each bf_rvs-line no-lock where
                   bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
          :
           find last  old_c-rvs-line no-lock where
                      old_c-rvs-line.rvs-code         = bf_rvs-line.rvs-code and
                      old_c-rvs-line.obj-type         = bf_rvs-line.obj-type and
                      old_c-rvs-line.obj-code         = bf_rvs-line.obj-code and
                      old_c-rvs-line.pl-code          = bf_rvs-line.pl-code and
                      old_c-rvs-line.gds-code         = bf_rvs-line.gds-code and
                      old_c-rvs-line.corr-user-db-num = g#db-num           and
                      old_c-rvs-line.chip-num        <= j-chip-num
                      no-error .
            if available old_c-rvs-line then do:
                v-result-field = "" .

                buffer-compare ub.c-rvs-line
                  except chip-num
                        corr-user-db-num
                  to  bf_rvs-line
                  save result in v-result-field no-error  .
            end.
            if not available old_c-rvs-line  or v-result-field <> ""
            then do:
              create ub.c-rvs-line .
              buffer-copy bf_rvs-line to ub.c-rvs-line .
              assign
                ub.c-rvs-line.chip-num         = j-chip-num
                ub.c-rvs-line.corr-user-db-num = g#db-num
                .
            end.
          end.

          for each bf_rvs-line-pump no-lock where
                   bf_rvs-line-pump.rvs-code = bf_rvs-doc.rvs-code
          :
           find last  old_c-rvs-line-pump no-lock where
                      old_c-rvs-line-pump.rvs-code         = bf_rvs-line-pump.rvs-code and
                      old_c-rvs-line-pump.obj-type         = bf_rvs-line-pump.obj-type and
                      old_c-rvs-line-pump.obj-code         = bf_rvs-line-pump.obj-code and
                      old_c-rvs-line-pump.pl-code          = bf_rvs-line-pump.pl-code and
                      old_c-rvs-line-pump.gds-code         = bf_rvs-line-pump.gds-code and
                      old_c-rvs-line-pump.pump-code        = bf_rvs-line-pump.pump-code and
                      old_c-rvs-line-pump.nozzle-code      = bf_rvs-line-pump.nozzle-code and
                      old_c-rvs-line-pump.corr-user-db-num = g#db-num           and
                      old_c-rvs-line-pump.chip-num        <= j-chip-num
                      no-error .
            if available old_c-rvs-line then do:
                v-result-field = "" .

                buffer-compare ub.c-rvs-line-pump
                  except chip-num
                        corr-user-db-num
                  to  bf_rvs-line
                  save result in v-result-field no-error  .
            end.
            if not available old_c-rvs-line-pump  or v-result-field <> ""
            then do:
              create ub.c-rvs-line-pump .
              buffer-copy bf_rvs-line-pump to ub.c-rvs-line-pump .
              assign
                ub.c-rvs-line-pump.chip-num         = j-chip-num
                ub.c-rvs-line-pump.corr-user-db-num = g#db-num
                .
            end.
          end.
  end.

define buffer bf_doc-attr      for ub.doc-attr      .
define buffer old_c-doc-attr for ub.c-doc-attr  .

  for each bf_doc-attr no-lock where
           bf_doc-attr.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-attr no-lock where
               old_c-doc-attr.doc-code         = bf_doc-attr.doc-code   and
               old_c-doc-attr.attr-code        = bf_doc-attr.attr-code  and
               old_c-doc-attr.corr-user-db-num = g#db-num               and
               old_c-doc-attr.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-attr then do:
        v-result-field = "" .

        buffer-compare ub.c-doc-attr
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-attr
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-attr  or v-result-field <> ""
    then do:
      create ub.c-doc-attr .
      buffer-copy bf_doc-attr to ub.c-doc-attr .
      assign
        ub.c-doc-attr.chip-num         = j-chip-num
        ub.c-doc-attr.corr-user-db-num = g#db-num
        .
    end.
  end.
define buffer bf_doc-line-sum  for ub.doc-line-sum  .
define buffer old_c-doc-line-sum for ub.c-doc-line-sum  .

  for each bf_doc-line-sum no-lock where
           bf_doc-line-sum.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-line-sum no-lock where
               old_c-doc-line-sum.doc-code         = bf_doc-line-sum.doc-code  and
               old_c-doc-line-sum.gds-code         = bf_doc-line-sum.gds-code  and
               old_c-doc-line-sum.sum-type         = bf_doc-line-sum.sum-type  and
               old_c-doc-line-sum.corr-user-db-num = g#db-num                  and
               old_c-doc-line-sum.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-line-sum then do:
        v-result-field = "" .

        buffer-compare ub.c-doc-line-sum
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-line-sum
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-line-sum  or v-result-field <> ""
    then do:
      create ub.c-doc-line-sum .
      buffer-copy bf_doc-line-sum to ub.c-doc-line-sum .
      assign
        ub.c-doc-line-sum.chip-num         = j-chip-num
        ub.c-doc-line-sum.corr-user-db-num = g#db-num
        .
    end.
  end.

define buffer bf_doc-line-attr for ub.doc-line-attr .
define buffer old_c-doc-line-attr for ub.c-doc-line-attr  .

  for each bf_doc-line-attr no-lock where
           bf_doc-line-attr.doc-code = p-bf_trn-doc.doc-code
  :
    find last  old_c-doc-line-attr no-lock where
               old_c-doc-line-attr.doc-code         = bf_doc-line-attr.doc-code   and
               old_c-doc-line-attr.gds-code         = bf_doc-line-attr.gds-code  and
               old_c-doc-line-attr.attr-code        = bf_doc-line-attr.attr-code  and
               old_c-doc-line-attr.corr-user-db-num = g#db-num               and
               old_c-doc-line-attr.chip-num        <= j-chip-num
               no-error .
    if available old_c-doc-line-attr then do:
        v-result-field = "" .

        buffer-compare ub.c-doc-line-attr
          except chip-num
                 corr-date
                 corr-time
                 corr-user-name
                 corr-user-db-num
          to  bf_doc-line-attr
          save result in v-result-field no-error  .
    end.
    if not available old_c-doc-line-attr  or v-result-field <> ""
    then do:
      create ub.c-doc-line-attr .
      buffer-copy bf_doc-line-attr to ub.c-doc-line-attr .
      assign
        ub.c-doc-line-attr.chip-num         = j-chip-num
        ub.c-doc-line-attr.corr-user-db-num = g#db-num
        .
    end.
  end.

end. /* Main-Block */