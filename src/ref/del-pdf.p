block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-pdf.p $
$Archive: ref/del-pdf.p $

Процедура удалить цены

Автор: Чернова Светлана Александровна
Дата создания: 02/15/06
Author: Svetlana Chernova
Creation date: 02/15/06

*/
define input  parameter parParentproc as handle no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-pdf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/del-pdf.p $":U .
define variable vss-description as character no-undo init "Процедура удалить цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define variable v-ask as logical   no-undo .

define buffer buf_price-doc-forming for ub.price-doc-forming  .

    for each buf_price-doc-forming exclusive-lock where
             buf_price-doc-forming.plt-id     = p-id     and
             buf_price-doc-forming.plt-db-num = p-db-num
             :
             buf_price-doc-forming.stts = integer({&pdf-delete}) .
             release buf_price-doc-forming.
     end.

       /* посылаем на кассу , если нужно , информацию о том что данные надо обновить */
       for each  ub.price-doc-forming no-lock  where
                 ub.price-doc-forming.plt-db-num   = p-db-num  and
                 ub.price-doc-forming.plt-id       = p-id :

    /* Отправка на кассы , если нужно */
          { gbl/a-nwspdf.i
            ub.price-doc-forming.plt-id
            ub.price-doc-forming.plt-db-num
            ub.price-doc-forming.pdf-id
            ub.price-doc-forming.pdf-db
            v-ask
          }

          if v-ask then do: /* Нужно отправлять */
            run str/diallog.w
                    ( input parparentproc
                    , input this-procedure
                    , input 'str/sendpdfr.p':U
                    , input ("D":U + {&delim-par} +
                            string(ub.price-doc-forming.plt-id) + {&delim-par}  +
                            string(ub.price-doc-forming.plt-db-num) + {&delim-par} +
                            string(ub.price-doc-forming.pdf-id) + {&delim-par}  +
                            string(ub.price-doc-forming.pdf-db)
                            )
                    , input yes /*p-auto-go*/
                    , input '':U
                    , input '') no-error .
                    if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "str/sendpdfr.p"
                      view-as alert-box error
                    .
                    end.
          end.
    end.

/* удалить ДНЦ по дочерним ТПЛ */
define buffer ch_price-list-type for ub.price-list-type .

for each ch_price-list-type no-lock  where
         ch_price-list-type.plt-main-id     = p-id     and
         ch_price-list-type.plt-main-db-num = p-db-num :

        for each buf_price-doc-forming exclusive-lock where
                 buf_price-doc-forming.plt-id     = ch_price-list-type.plt-id     and
                 buf_price-doc-forming.plt-db-num = ch_price-list-type.plt-db-num
                 :
                 buf_price-doc-forming.stts = integer({&pdf-delete}) .
                 release buf_price-doc-forming.
        end.
       /* посылаем на кассу , если нужно , информацию о том что данные надо обновить */
       for each  ub.price-doc-forming no-lock  where
                 ub.price-doc-forming.plt-db-num   = ch_price-list-type.plt-db-num  and
                 ub.price-doc-forming.plt-id       = ch_price-list-type.plt-id :

    /* Отправка на кассы , если нужно */
          { gbl/a-nwspdf.i
            ub.price-doc-forming.plt-id
            ub.price-doc-forming.plt-db-num
            ub.price-doc-forming.pdf-id
            ub.price-doc-forming.pdf-db
            v-ask
          }
          if v-ask then do: /* Нужно отправлять */
            run str/diallog.w
                    ( input parparentproc
                    , input this-procedure
                    , input 'str/sendpdfr.p':U
                    , input ("D":U + {&delim-par} +
                            string(ub.price-doc-forming.plt-id) + {&delim-par}  +
                            string(ub.price-doc-forming.plt-db-num) + {&delim-par} +
                            string(ub.price-doc-forming.pdf-id) + {&delim-par}  +
                            string(ub.price-doc-forming.pdf-db)
                            )
                    , input yes /*p-auto-go*/
                    , input '':U
                    , input '') no-error .
                    if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "str/sendpdfr.p"
                      view-as alert-box error
                    .
                    end.
          end.
          end.


end.