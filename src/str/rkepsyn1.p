block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rkepsyn1.p $
$Archive: str/rkepsyn1.p $

Синхронизация данных по товарам в IBS TH с данными по товарам на кассе R-keeper

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/18/05
Author: Bakhtadze Natalya
Creation date: 02/18/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
define variable p-curr-obj-type like ub.clients.obj-type no-undo .
define variable p-curr-obj-code like ub.clients.obj-code no-undo .
define variable p-rid-list as character no-undo .
define variable p-options as character no-undo .
*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkepsyn1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsyn1.p $":U .
define variable vss-description as character no-undo init "Синхронизация данных по товарам в IBS TH с данными по товарам на кассе R-keeper".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable p-curr-obj-type like ub.clients.obj-type no-undo .
define variable p-curr-obj-code like ub.clients.obj-code no-undo .
define variable p-rid-list as character no-undo .
define variable p-options as character no-undo .

define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable ii as integer no-undo .


do
on error undo, return error return-value
:

  assign
  p-curr-obj-type      = entry(1, p-parameter, {&delim-par})
  p-curr-obj-code      = integer(entry(2, p-parameter, {&delim-par}))
  p-rid-list           = entry(3, p-parameter, {&delim-par})
  p-options            = entry(4, p-parameter, {&delim-par})
  no-error
  .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка входных параметров &1:&2&3&4"
                          , p-parameter
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
    {&view-log}.
  end.
  do ii = 1 to num-entries(p-options):
    CASE entry(ii, p-options):
      when "name":U then do:
        run hide-counter in p-log-handle .
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Синхронизация названий товаров на кассах R-KEEPER и в IBS TH....."
                              )).
        run str/rkepsynm.p (
                           input parparentproc
                          ,input p-parent-handle
                          ,input p-log-handle
                          ,input p-rid-list
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                       ) no-error .
      end.
      when "price":U then do:
        run hide-counter in p-log-handle .
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Синхронизация цен товаров на кассах R-KEEPER и в IBS TH....."
                              )).
        run str/rkepsypr.p (
                           input parparentproc
                          ,input p-parent-handle
                          ,input p-log-handle
                          ,input p-rid-list
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                       ) no-error .

      end.
      when "group":U then do:
        run hide-counter in p-log-handle .
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Синхронизация принадлежности товаров к группам на кассах R-KEEPER и в IBS TH....."
                              )).

        run str/rkepsygr.p (
                           input parparentproc
                          ,input p-parent-handle
                          ,input p-log-handle
                          ,input p-rid-list
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                       ) no-error .

      end.
      when "modificator" then do:
        run hide-counter in p-log-handle .
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Синхронизация признаков МОДИФИКАТОР и НУЛЕВАЯ ЦЕНА у товаров на кассах R-KEEPER и в IBS TH....."
                              )).

        run str/rkepsymd.p (
                           input parparentproc
                          ,input p-parent-handle
                          ,input p-log-handle
                          ,input p-rid-list
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                       ) no-error .

      end.
    END CASE.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!! Ошибка выполнения!&1&2 &3"
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              )).

    end.
  end.
end.