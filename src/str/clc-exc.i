/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акциз

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/11/06

*/
FUNCTION calc-excise RETURNS DECIMAL(input  parprice-sale as decimal,
                                     input  parroad-tax   as decimal,
                                     input  parvat-pc     as decimal,
                                     input  parfactorrd   as decimal,
                                     output parexcise     as decimal):
ASSIGN parexcise = (parprice-sale - parroad-tax) * parvat-pc / (100 + parvat-pc) -
                   1 / parfactorrd * parroad-tax.
RETURN parexcise.
END FUNCTION.