/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Передача изменений из Шаблона в прикрепленные АссМатрицы

Автор: Чернова Светлана Александровна
Дата создания: 07/08/09
Author: Svetlana Chernova
Creation date: 07/08/09


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-longchar-asstro  as longchar no-undo .

define temp-table temp-goods no-undo
  field gds-code as integer
  field status_  as integer
  index pi gds-code
.



PROCEDURE translate-to-other :
define input  parameter p-asmt-id as integer   no-undo . /* Шаблон */
define input  parameter p-db-num  as integer   no-undo . /* Шаблон */
  do
  on error undo, return error return-value
  :

define variable v-recid as recid no-undo .

define buffer Oth_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .
define buffer bufs_gds-obj-prop for ub.gds-obj-prop  .


  find first  sh_assortment-matrix no-lock where
              sh_assortment-matrix.asmt-id = p-asmt-id and
              sh_assortment-matrix.db-num  = p-db-num  and
              sh_assortment-matrix.asmt-status = 0 and
              sh_assortment-matrix.asmt-type = {&type-assmatr-shablon} no-error .
if not available sh_assortment-matrix then return .

define variable v-doc-rec as recid no-undo .
define variable v-gds-prop-recid as recid no-undo .
define variable v-stt as integer   no-undo .
v-longchar-asstro = "".
   run waitfram-show in this-procedure  ("Передача изменений в связанные матрицы ... " ) .
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = {&type-assmatr-obj} ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = {&assmatat-RootShablon} and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , p-asmt-id, p-db-num,{&delim-par})
            :
        run waitfram-show in this-procedure ( substitute(" Передаю изменения в Матрицу: &1" ,obj_assortment-matrix.asmt-name )) .
        for each temp-goods :
           if temp-goods.status_ = 0 then do:
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = temp-goods.gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if not available Oth_assortment-matrix-goods then do:
                      { ref/gds-mat1.i
                        this-procedure
                        v-doc-rec
                        {&add-def}
                        ub.assortment-matrix-attr.asmt-id
                        ub.assortment-matrix-attr.db-num
                        temp-goods.gds-code
                        "''"
                        no-error }
                        if error-status :error then do:
                          v-longchar-asstro = v-longchar-asstro + return-value + {&new-line} .
                          next.
                        end.
                    end.
              end.
              else do:
                v-stt = 1.
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = temp-goods.gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if available Oth_assortment-matrix-goods then do:

                        v-recid = recid(Oth_assortment-matrix-goods).
                        find first bufs_gds-obj-prop exclusive-lock where
                                   bufs_gds-obj-prop.gds-code = Oth_assortment-matrix-goods.gds-code   and
                                   bufs_gds-obj-prop.obj-type = Oth_assortment-matrix-goods.obj-type   and
                                   bufs_gds-obj-prop.obj-code = Oth_assortment-matrix-goods.obj-code  no-error .
                        if not available bufs_gds-obj-prop
                          or not (bufs_gds-obj-prop.gdop-igt = {&ass-izd-empty} or
                                  bufs_gds-obj-prop.gdop-igt = {&ass-izd-del} ) then do:
                        v-longchar-asstro = v-longchar-asstro +
                        substitute("Принудительная смена ИЖТ_ товара &1  на ПУСТО на объекте &2&3&4" ,
                            Oth_assortment-matrix-goods.gds-code ,
                            Oth_assortment-matrix-goods.obj-type ,
                            Oth_assortment-matrix-goods.obj-code ,
                            {&new-line}) .
                        run gds-ind1
                            (input-output v-gds-prop-recid
                            ,Oth_assortment-matrix-goods.gds-code
                            ,Oth_assortment-matrix-goods.obj-type
                            ,Oth_assortment-matrix-goods.obj-code
                            ,{&ass-izd-empty}
                            ,?
                            ,?
                            ,?
                            ,?
                            ,?
                            ) no-error  .
                          end.
                          if not error-status :error then do:
                              { ref/gds-mat2.i
                                this-procedure
                                v-recid
                                v-stt
                                no
                                no-error }
                                if error-status :error then do:
                                   v-longchar-asstro = v-longchar-asstro + return-value + {&new-line} .
                                end.
                           end.
                           else do:
                              v-longchar-asstro = v-longchar-asstro + return-value + {&new-line} .
                           end.
                    end.
               end.
        end.
   end.
   run waitfram-hide in this-procedure.
end.
END PROCEDURE.


PROCEDURE translate-to-other-gds :
define input  parameter p-asmt-id  as integer   no-undo . /* Шаблон */
define input  parameter p-db-num   as integer   no-undo . /* Шаблон */
define input  parameter p-gds-code as integer   no-undo . /* Товар */
define input  parameter p-status_  as integer   no-undo . /* Добавляем или удаляем */

  do
  on error undo, return error return-value
  :

define buffer Oth_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .
define buffer bufs_gds-obj-prop for ub.gds-obj-prop  .

  find first  sh_assortment-matrix no-lock where
              sh_assortment-matrix.asmt-id = p-asmt-id and
              sh_assortment-matrix.db-num  = p-db-num  and
              sh_assortment-matrix.asmt-status = 0 and
              sh_assortment-matrix.asmt-type = {&type-assmatr-shablon} no-error .
if not available sh_assortment-matrix then return .

define variable v-doc-rec as recid no-undo .
define variable v-gds-prop-recid as recid no-undo .
define variable v-stt as integer   no-undo .
define variable v-recid as recid no-undo .
 v-longchar-asstro = "" .
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = {&type-assmatr-obj} ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = {&assmatat-RootShablon} and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , p-asmt-id, p-db-num,{&delim-par})
            :
           if p-status_ = 0 then do:
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = p-gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if not available Oth_assortment-matrix-goods then do:
                      { ref/gds-mat1.i
                        this-procedure
                        v-doc-rec
                        {&add-def}
                        ub.assortment-matrix-attr.asmt-id
                        ub.assortment-matrix-attr.db-num
                        p-gds-code
                        "''"
                        no-error }
                        if error-status :error then do:
                           v-longchar-asstro = v-longchar-asstro + return-value + {&new-line} .
                           next.
                        end.
                    end.
              end.
              else do:
                v-stt = 1.
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = p-gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if available Oth_assortment-matrix-goods then do:
                        v-recid = recid(Oth_assortment-matrix-goods) .
                        find first bufs_gds-obj-prop exclusive-lock where
                                   bufs_gds-obj-prop.gds-code = Oth_assortment-matrix-goods.gds-code   and
                                   bufs_gds-obj-prop.obj-type = Oth_assortment-matrix-goods.obj-type   and
                                   bufs_gds-obj-prop.obj-code = Oth_assortment-matrix-goods.obj-code  no-error .
                        if not available bufs_gds-obj-prop
                          or not (bufs_gds-obj-prop.gdop-igt = {&ass-izd-empty} or
                                  bufs_gds-obj-prop.gdop-igt = {&ass-izd-del} ) then do:

                        v-longchar-asstro = v-longchar-asstro +
                        substitute("Принудительная смена ИЖТ. товара &1  на ПУСТО на объекте &2&3&4" ,
                            Oth_assortment-matrix-goods.gds-code ,
                            Oth_assortment-matrix-goods.obj-type ,
                            Oth_assortment-matrix-goods.obj-code ,
                            {&new-line}) .
                        run gds-ind1
                            (input-output v-gds-prop-recid
                            ,Oth_assortment-matrix-goods.gds-code
                            ,Oth_assortment-matrix-goods.obj-type
                            ,Oth_assortment-matrix-goods.obj-code
                            ,{&ass-izd-empty}
                            ,?
                            ,?
                            ,?
                            ,?
                            ,?
                            ) no-error  .
                           end.
                           if not error-status :error then do:
                              { ref/gds-mat2.i
                                this-procedure
                                v-recid
                                v-stt
                                no
                                no-error }
                                if error-status :error then do:
                                   v-longchar-asstro = v-longchar-asstro + return-value + {&new-line} .
                                end.
                           end.
                           else do:
                             v-longchar-asstro = v-longchar-asstro + return-value + {&new-line} .
                           end.
                    end.
               end.
   end.
end.

END PROCEDURE.
/* $Workfile$ e n d */