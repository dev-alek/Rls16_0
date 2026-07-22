/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость по контрагентам (повторяющийся вывод в Excel)

Автор: Комаров Иван Сергеевич
Дата создания: 12/14/09
Author: Ivan Komarov
Creation date: 12/14/09

*/

if p-detdoctip = true then do:
if v-print-rubl = true then do:
    if show-cost = true then do:
                run macr_excel_dec in this-procedure (input {1}ras-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10           /* p-size   */
                  ,input {2}          /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}cost-sum-rubl-ras, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10           /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input {1}ret-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}cost-sum-rubl-ret, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
    end.
    else do:
                run macr_excel_dec in this-procedure (input {1}ras-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}sale-sum-rubl-ras, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input {1}ret-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}sale-sum-rubl-ret, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
    end.
  end.
  else do:
    if show-cost = true then do:
                run macr_excel_dec in this-procedure (input {1}ras-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}cost-sum-base-ras, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input {1}ret-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}cost-sum-base-ret, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
    end.
    else do:
                run macr_excel_dec in this-procedure (input {1}ras-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}sale-sum-base-ras, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_char in this-procedure (input {1}ret-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_char in this-procedure (input string({1}sale-sum-base-ret, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
    end.
  end.
end.
if v-print-rubl = true then do:
    if show-cost = true then do:
                run macr_excel_dec in this-procedure (input {1}all-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}cost-sum-rubl-all, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                num#str# = num#str# + 1.
    end.
    else do:
                run macr_excel_dec in this-procedure (input {1}all-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}sale-sum-rubl-all, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                num#str# = num#str# + 1.
    end.
  end.
  else do:
    if show-cost = true then do:
                run macr_excel_dec in this-procedure (input {1}all-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}cost-sum-base-all, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                num#str# = num#str# + 1.
    end.
    else do:
                run macr_excel_dec in this-procedure (input {1}all-qnty, input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                run macr_excel_dec in this-procedure (input string({1}sale-sum-base-all, "->>>>>>>>9.99"), input num#str#, input num#col# ) .
                run macr_cell_format in this-procedure
                  (input 10            /* p-size   */
                  ,input {2}         /* p-bold   */
                  ,input false        /* p-italic */
                  ,input ?            /* p-color  */
                  ,input num#str#     /* p-row    */
                  ,input num#col#     /* p-col    */
                  ,input ?            /* p-row-2  */
                  ,input ?            /* p-col-2  */
                  ) .
                num#col# = num#col# + 1.
                num#str# = num#str# + 1.
    end.
end.