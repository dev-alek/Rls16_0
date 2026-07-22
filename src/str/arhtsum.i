/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюдник для заполнения сумм архивов по документу МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 06/09/08
Author: Polina Gridchina
Creation date: 06/09/08


*/


    assign {1}.in-qnty     = {1}.in-qnty     + buf_wth-parts.fact-qnty
           {1}.in-sum-rubl = {1}.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           {1}.in-sum-base = {1}.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
    else   assign {1}.out-qnty  = {1}.out-qnty + buf_wth-parts.fact-qnty
           {1}.out-sum-rubl = {1}.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           {1}.out-sum-base = {1}.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .