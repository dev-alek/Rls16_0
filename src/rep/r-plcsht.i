/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 09/18/07
Author: Ilia Belousov
Creation date: 09/18/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


            IF (buf_rvs-doc.rvs-type = {&rvs-after-doc}
            OR  buf_rvs-doc.rvs-type = {&rvs-before-doc})
            then do:
               find first buf_trn-doc
                    where buf_trn-doc.doc-code = buf_rvs-doc.out-code
                    no-lock
                    .
               v-attr = "".
            end.

            FOR each  buf_rvs-line
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            no-lock
            :
               find first buf_place
                     where buf_place.obj-type = buf_rvs-doc.obj-type
                     and buf_place.obj-code = buf_rvs-doc.obj-code
                     and buf_place.pl-code  = buf_rvs-line.pl-code
                     no-lock
                     no-error
                     .
               if available buf_place then do:
                  assign
                     v-loc = buf_place.loc1
                  .
               end.
               else do:
                  assign
                     v-loc = "Не найден"
                  .
               end.

               find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line.gds-code
                  no-lock
                  .
               if  available buf_trn-doc
               AND (buf_rvs-doc.rvs-type = {&rvs-after-doc}
               OR   buf_rvs-doc.rvs-type = {&rvs-before-doc})
               then do:
                  find first buf_doc-line
                       where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                         and buf_doc-line.artic     = buf_goods.artic
                         and buf_doc-line.prod-type = buf_goods.prod-type
                         and buf_doc-line.prod-code = buf_goods.prod-code
                       no-lock
                       .
                        assign
                           v-exist = false
                        .
                        /* перевозчик  type */
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-type":U ,
                           OUTPUT  v-autoent-type      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-type = ""
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        /* перевозчик  code */
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-code":U ,
                           OUTPUT  v-autoent-code      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-code = ""
                           .
                        END.
                        find first buf_clients
                              where buf_clients.obj-type = v-autoent-type
                                 and buf_clients.obj-code = INTEGER(v-autoent-code)
                              no-lock
                              no-error
                              .
                        IF AVAILABLE buf_clients then do:
                           assign
                              v-autoent-name = buf_clients.obj-name
                           .
                        end.
                        else do:
                           assign
                              v-autoent-name = "не задан":U
                           .
                        end.
                        assign
                           v-exist = false
                        .
                        /* № а/м */
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "car-num":U ,
                           OUTPUT  v-car-num      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-car-num = "не задан"
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        /* водитель */
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "fio":U ,
                           OUTPUT  v-fio      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-fio = "не заданы"
                           .
                        END.


















































                  assign
                     v-attr = Substitute( "Перевозчик: &1, № а/м: &2, ФИО водителя: &3, плотность: &4, температура: &5, масса: &6, объем: &7"
                                        , v-autoent-name
                                        , v-car-num
                                        , v-fio
                                        , STRING(buf_doc-line.doc-density, ">9.9999")
                                        , STRING(buf_doc-line.temperature, "->9.99")
                                        , buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                        , buf_doc-line.doc-qnty
                                        )
                  .
                  release buf_doc-line.
               end.
               create tt-doc.
               assign
                  tt-doc.rvs-code           = buf_rvs-line.rvs-code
                  tt-doc.obj-type           = buf_rvs-line.obj-type
                  tt-doc.obj-code           = buf_rvs-line.obj-code
                  tt-doc.pl-code            = buf_rvs-line.pl-code
                  tt-doc.gds-code           = buf_rvs-line.gds-code
                  tt-doc.shift-date         = buf_rvs-doc.shift-date
                  tt-doc.shift-num          = buf_rvs-doc.shift-num
                  tt-doc.status_            = buf_rvs-doc.status_
                  tt-doc.fact-order         = buf_rvs-doc.fact-order
                  tt-doc.loc1               = v-loc
                  tt-doc.state-measure-qnty = buf_rvs-line.state-measure-qnty
                  tt-doc.state-temperature  = buf_rvs-line.state-temperature
                  tt-doc.state-dencity      = buf_rvs-line.state-density
                  tt-doc.fact-date          = buf_rvs-doc.fact-date
                  tt-doc.fact-time          = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
                  tt-doc.gds-name           = buf_goods.gds-name
                  tt-doc.rvs-type           = buf_rvs-doc.rvs-type
                  tt-doc.state-level-total  = buf_rvs-line.state-level-total
                  tt-doc.attr_              = v-attr
               .
               case tt-doc.rvs-type:
                  when {&rvs-after-doc} then do:
                     assign
                        tt-doc.rvs-type-outside = "после приема"
                     .
                  end.
                  when     {&rvs-before-doc} then do:
                     assign
                        tt-doc.rvs-type-outside = "до приема"
                     .
                  end.
                  when     {&rvs-shift} then do:
                     assign
                        tt-doc.rvs-type-outside = "смена"
                     .
                  end.
                  when     {&rvs-control} then do:
                     assign
                        tt-doc.rvs-type-outside = "контроль"
                     .
                  end.
               end case.
            if  available buf_trn-doc then do:
                release buf_trn-doc.
            end.

/* $Workfile$ e n d */