block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-in-cr.p $
$Archive: rep/r-in-cr.p $

Это кусок от r-o-prt  создание полей (невлазил в основную по e-code)

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/14/03 11:49

*/
def input parameter x-base-type  like ub.currency.curr-abbr no-undo.
def input parameter x-base-code  like ub.currency.curr-code no-undo.
def input-output  parameter c-nn             as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-artic        as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-b-code       as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-gds-name     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-qnty         as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-cost-sum     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-sale-sum     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-sale-other   as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-crsa-sum     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-qnty-all     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-cost-sum-all as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-sale-sum-all as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-crsa-sum-all as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-qnty-o       as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-cost-sum-o   as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-crsa-sum-o   as WIDGET-HANDLE no-undo .

define input parameter   tPrintRubl    as log no-undo .

{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i  " "  100  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }

&scop l-frame 300
&scop l-frame-1 198
def  stream  OutStream .

{ rep/r-ob3cr.i def    6  " "            shared  }
{ rep/r-ob3cr.i def-cr 1  nn             shared  }
{ rep/r-ob3cr.i def-cr 2  f-b-code       shared  }
{ rep/r-ob3cr.i def-cr 3  f-artic        shared  }
{ rep/r-ob3cr.i def-cr 4  f-gds-name     shared  }
{ rep/r-ob3cr.i def-cr 5  f-qnty         shared  }
{ rep/r-ob3cr.i def-cr 6  f-cost-sum     shared  }
{ rep/r-ob3cr.i def-cr 7  f-sale-sum     shared  }
{ rep/r-ob3cr.i def-cr 8  f-sale-other   shared  }
{ rep/r-ob3cr.i def-cr 9  f-crsa-sum     shared  }
{ rep/r-ob3cr.i def-cr 10 f-qnty-all     shared  }
{ rep/r-ob3cr.i def-cr 11 f-cost-sum-all shared  }
{ rep/r-ob3cr.i def-cr 12 f-crsa-sum-all shared  }
{ rep/r-ob3cr.i def-cr 13   f-qnty-o     shared  }
{ rep/r-ob3cr.i def-cr 14   f-cost-sum-o shared  }
{ rep/r-ob3cr.i def-cr 15   f-crsa-sum-o shared  }
{ rep/r-ob3cr.i def-cr2 16  top-frame    shared  }
{ rep/r-ob3cr.i def-cr2 17  top-frame    shared  }
{ rep/r-ob3cr.i def-cr2 18  top-frame    shared  }
{ rep/r-ob3cr.i def-cr2 19  top-frame    shared  }

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-row-pos = 3.
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=6  l-col-format= "X(6)"         l-col-lable="N/N"                      . { rep/r-ob3cr.i cr 1  nn               }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"        l-col-lable="Код"                      . { rep/r-ob3cr.i cr 2  f-b-code         }
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"        l-col-lable="Артикул"                  . { rep/r-ob3cr.i cr 3  f-artic          }
Assign l-col-type="CHARACTER" l-col-len=25 l-col-format= "X(25)"        l-col-lable="Название товара"          . { rep/r-ob3cr.i cr 4  f-gds-name       }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество "           .    { rep/r-ob3cr.i cr 5  f-qnty           }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   . { rep/r-ob3cr.i cr 6  f-cost-sum       }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в ценах документа" . { rep/r-ob3cr.i cr 7  f-sale-sum       }
Assign l-col-type="DECIMAL" l-col-len=10 l-col-format="->>>>>>>9.<<"  l-col-lable="В т.ч. скидка"      .         { rep/r-ob3cr.i cr 8  f-sale-other     }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" . { rep/r-ob3cr.i cr 9  f-crsa-sum       }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество"            .    { rep/r-ob3cr.i cr 10 f-qnty-all       }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   . { rep/r-ob3cr.i cr 11 f-cost-sum-all   }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" . { rep/r-ob3cr.i cr 12 f-crsa-sum-all   }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество "           .    { rep/r-ob3cr.i cr 13   f-qnty-o         }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"    l-col-lable="Сумма в учетных ценах" . { rep/r-ob3cr.i cr 14 f-cost-sum-o     }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" . { rep/r-ob3cr.i cr 15   f-crsa-sum-o     }
l-row-pos = 1.
l-col-pos = 1.

Assign l-col-type="CHARACTER"
       l-col-len= -1 +
                  (if  c-nn         <> ? then  c-nn:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-b-code   <> ? then  c-f-b-code:WIDTH-CHARS  + 1     Else 0 ) +
                  (if  c-f-artic    <> ? then  c-f-artic:WIDTH-CHARS  + 1      Else 0 ) +
                  (if  c-f-gds-name <> ? then  c-f-gds-name:WIDTH-CHARS + 1    Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Товар"                .
       { rep/r-ob3cr.i cr2 16  top-frame  }
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty       <> ? then  c-f-qnty:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum   <> ? then  c-f-cost-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-sum   <> ? then  c-f-sale-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-other <> ? then  c-f-sale-other:WIDTH-CHARS + 1  Else 0 ) +
                  (if  c-f-crsa-sum   <> ? then  c-f-crsa-sum:WIDTH-CHARS + 1    Else 0 )


       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Оборот (выборочно)"   .
       { rep/r-ob3cr.i cr2 17  top-frame  }
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty-all     <> ? then  c-f-qnty-all:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum-all <> ? then  c-f-cost-sum-all:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-crsa-sum-all <> ? then  c-f-crsa-sum-all:WIDTH-CHARS + 1    Else 0 )

       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Весь оборот за период".
       { rep/r-ob3cr.i cr2 18  top-frame  }
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty-o     <> ? then  c-f-qnty-o:WIDTH-CHARS  + 1   Else 0 ) +
                  (if  c-f-cost-sum-o <> ? then  c-f-cost-sum-o:WIDTH-CHARS  + 1     Else 0 ) +
                  (if  c-f-crsa-sum-o <> ? then  c-f-crsa-sum-o:WIDTH-CHARS  + 1   Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Остатки"              .
       { rep/r-ob3cr.i cr2 19  top-frame  }