block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: any-li01.p $
$Archive: str/any-li01.p $

Обработка заполнения списка товаров - процедура 01

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/06
Author: Bakhtadze Natalya
Creation date: 08/03/06

*/


define input parameter parparentproc   as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-proc-name     as character no-undo .
define input parameter p-from-macro    as logical no-undo .
define input parameter rs-list-method  as character no-undo .
define input parameter rs-status       as character no-undo .
define input parameter line-mode       as character no-undo .
define input parameter p-id            as integer no-undo .
{ cmp/listhist.i any }
define INPUT-OUTPUT parameter table for any-hist.



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: any-li01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/any-li01.p $":U .
define variable vss-description as character no-undo init "Обработка заполнения списка товаров - процедура 01".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }


define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .



define buffer buf_goods for ub.goods.
define buffer buf_any-hist for any-hist.
define buffer buf_user-obj for ub.user-obj.

define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .

&glob get-rowid  run gen-row-keyr  in p-parent-handle  (  input buf_any-hist.item_  ~  ~
                                                       ,input ?                   ~
                                                       ,input 'ub'                ~
                                                       ,input ?                   ~
                                                       ,input no-lock             ~
                                                       ,output v-rowid           ~
                                                       ,output v-tbl-name) no-error . ~
                 if error-status:error then




case p-proc-name :
  when "analysis-do":U then do:
    do
    on error undo, return error return-value:
      CASE rs-list-method:
        when "abc-analysis" then do:
          find first buf_any-hist where
                    buf_any-hist.id = p-id .
          {&get-rowid} do: end. else do:
            find first ub.abc-analysis no-lock where
                      rowid(ub.abc-analysis) = v-rowid no-error.
            if avail ub.abc-analysis then do:
              _abc:
              for each buf_any-hist where
                      buf_any-hist.id = p-id
                  and  buf_any-hist.item_ <> '':U:
                for each ub.abc-analysis-goods no-lock where
                        ub.abc-analysis-goods.abc-id  = ub.abc-analysis.abc-id
                    and ub.abc-analysis-goods.db-num   = ub.abc-analysis.db-num
                    and ub.abc-analysis-goods.abcg-abc = buf_any-hist.item_,
                  first buf_goods  no-lock where
                        buf_goods.gds-code = abc-analysis-goods.gds-code:
                  run ex-gds in p-parent-handle ( buffer buf_goods, input rs-list-method, input rs-status, input line-mode).
                end.
                run assign-nums in p-parent-handle ( input-output buf_any-hist.num-add
                                                    ,input-output buf_any-hist.num-rec
                                                    ,input-output buf_any-hist.num-ignored
                                                    ,input line-mode).

              end. /* for each buf_1-hist */
            end. /*if avail abc-analysis then do:*/
          end. /*{&get-rowid} do: end. else do:*/
        end.  /*when*/
        when "xyz-analysis" then do:
          find first buf_any-hist where
                    buf_any-hist.id = p-id .
          {&get-rowid} do: end. else do:
            find first ub.xyz-analysis no-lock where
                      rowid(ub.xyz-analysis) = v-rowid no-error.
            if avail ub.xyz-analysis then do:
              _xyz:
              for each buf_any-hist where
                      buf_any-hist.id = p-id
                  and  buf_any-hist.item_ <> '':U:
                for each ub.xyz-analysis-goods no-lock where
                        ub.xyz-analysis-goods.xyz-id  = ub.xyz-analysis.xyz-id
                    and ub.xyz-analysis-goods.db-num   = ub.xyz-analysis.db-num
                    and ub.xyz-analysis-goods.xyzg-xyz = buf_any-hist.item_,
                  first buf_goods  no-lock where
                        buf_goods.gds-code = xyz-analysis-goods.gds-code:
                  run ex-gds in p-parent-handle ( buffer buf_goods, input rs-list-method, input rs-status, input line-mode).
                end. /*for each xyz-analysis-goods*/
                run assign-nums in p-parent-handle ( input-output buf_any-hist.num-add
                                                    ,input-output buf_any-hist.num-rec
                                                    ,input-output buf_any-hist.num-ignored
                                                    ,input line-mode).
              end. /* for each buf_1-hist */
            end. /*if avail xyz-analysis then do:*/
          end. /*{&get-rowid} do: end. else do:*/
        end. /*hen "xyz-analysis" then do:*/
        when "abcxyz" then do:
          find first buf_any-hist where
                    buf_any-hist.id = p-id .
          {&get-rowid} do: end. else do:
            find first ub.abcxyz-analysis no-lock where
                      rowid(ub.abcxyz-analysis) = v-rowid no-error.
            if avail ub.abcxyz-analysis then do:
                _abcxyz:
                for each buf_any-hist where
                        buf_any-hist.id = p-id
                    and  buf_any-hist.item_ <> '':U:
                  for each ub.abcxyz-analysis-goods no-lock where
                          ub.abcxyz-analysis-goods.abcx-id  = ub.abcxyz-analysis.abcx-id
                      and ub.abcxyz-analysis-goods.db-num   = ub.abcxyz-analysis.db-num
                      and ub.abcxyz-analysis-goods.abcg-abc = substring(buf_any-hist.item_, 1, 1)
                      and ub.abcxyz-analysis-goods.xyzg-xyz = substring(buf_any-hist.item_, 2, 1),
                    first buf_goods  no-lock where
                          buf_goods.gds-code = abcxyz-analysis-goods.gds-code:
                    run ex-gds  in p-parent-handle ( buffer buf_goods, input rs-list-method, input rs-status, input line-mode).
                  end.
                  run assign-nums in p-parent-handle ( input-output buf_any-hist.num-add
                                                      ,input-output buf_any-hist.num-rec
                                                      ,input-output buf_any-hist.num-ignored
                                                      ,input line-mode).
                end. /* for each buf_1-hist */
              end. /*if avail abcxyz-analysis then do:*/
          end. /*if availa v-rowid*/
        end. /*when abcxyz*/
      END CASE.
    end. /*doe*/
  end. /*analysis-do*/
  when "ass-matr":U then do:
    do
    on error undo, return error return-value:

      for each buf_any-hist where
              buf_any-hist.id = p-id
          and  buf_any-hist.item_  <> '':U:
        {&get-rowid} next.
        find first ub.assortment-matrix no-lock where
                  rowid(ub.assortment-matrix) = v-rowid no-error.
        for each ub.assortment-matrix-goods no-lock where
                ub.assortment-matrix-goods.asmt-id  = ub.assortment-matrix.asmt-id
            and ub.assortment-matrix-goods.db-num        = ub.assortment-matrix.db-num
            and ub.assortment-matrix-goods.asmg-status   = int({&current-status-int}),
            first buf_goods  no-lock where
                buf_goods.gds-code = assortment-matrix-goods.gds-code:
          run ex-gds  in p-parent-handle ( buffer buf_goods, input rs-list-method, input rs-status, input line-mode).
        end.
        run assign-nums in p-parent-handle ( input-output buf_any-hist.num-add
                                            ,input-output buf_any-hist.num-rec
                                            ,input-output buf_any-hist.num-ignored
                                            ,input line-mode).
      end. /*each buf_1-hist*/
    end.
  end. /*ass-matr*/
  when "ass-min":U then do:
    do
    on error undo, return error return-value:
      for each buf_any-hist where
              buf_any-hist.id = p-id
          and  buf_any-hist.item_  <> '':U:
        v-obj-type = entry(1,buf_any-hist.item_, {&delim-key}) no-error  .
        v-obj-code = integer(entry(2,buf_any-hist.item_, {&delim-key})) no-error .

        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type and
                  buf_user-obj.obj-code = v-obj-code
                  no-error.
        if avail buf_user-obj then do:
          for each ub.gds-obj-prop no-lock where
                  ub.gds-obj-prop.obj-type = buf_user-obj.obj-type
              and ub.gds-obj-prop.obj-code  = buf_user-obj.obj-code
              and ub.gds-obj-prop.gdop-assort-min  = true,
              first buf_goods  no-lock where
                  buf_goods.gds-code = ub.gds-obj-prop.gds-code:
            run ex-gds in p-parent-handle ( buffer buf_goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        run assign-nums in p-parent-handle ( input-output buf_any-hist.num-add
                                            ,input-output buf_any-hist.num-rec
                                            ,input-output buf_any-hist.num-ignored
                                            ,input line-mode).
      end. /*for each buf_any-hist where*/
    end.
  end.
  when "collection":U then do:
    do on error undo, return error return-value:
      for each buf_any-hist where
               buf_any-hist.id = p-id
          and  buf_any-hist.item_  <> '':U:
        {&get-rowid} next.
        find first ub.season no-lock where
             rowid(ub.season) = v-rowid no-error.
        for each ub.gds-season no-lock where
                 ub.gds-season.sea-code  = ub.season.sea-code
             and ub.gds-season.db-num    = ub.season.db-num ,
            first buf_goods  no-lock where
                  buf_goods.gds-code = ub.gds-season.gds-code :
          run ex-gds  in p-parent-handle ( buffer buf_goods, input rs-list-method, input rs-status, input line-mode).
        end.
        run assign-nums in p-parent-handle ( input-output buf_any-hist.num-add
                                            ,input-output buf_any-hist.num-rec
                                            ,input-output buf_any-hist.num-ignored
                                            ,input line-mode).
      end. /*each buf_1-hist*/
     end.
  end. /*ass-matr*/
END CASE.