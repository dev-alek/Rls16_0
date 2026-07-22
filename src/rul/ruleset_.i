/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Препроцессинги для наборов правил и кодексов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/03/10
Author: Bakhtadze Natalya
Creation date: 03/03/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&global-define dct-proc_1                                      1

&global-define dct-proc_1_sale-close_1                         1
&global-define dct-proc_1_sale-delete_2                        2
&global-define dct-proc_1_trn-doc-close_3                      3
&global-define dct-proc_1_trn-doc-delete_4                     4
&global-define dct-proc_1_import_5                             5


&global-define dct-proc_2                                      2

&global-define dct-proc_2_sale-close_1                         1
&global-define dct-proc_2_sale-delete_2                        2
&global-define dct-proc_2_trn-doc-close_3                      3
&global-define dct-proc_2_trn-doc-delete_4                     4
&global-define dct-proc_2_import_6                             6

&global-define dct-proc_4_sale-xml-import_3                    3
&global-define dct-proc_text-import
&global-define dct-proc_text-export
&global-define dct-proc_one-card-recalc
&global-define dct-proc_one-card-check
&global-define dct-proc_one-card-add
&global-define dct-proc_2_batch-card-recalc_5                  5
&global-define dct-proc_stop-list-import
&global-define dct-proc_payment-on-card                        7
&global-define dct-proc_fin-doc-on-card
&global-define dct-proc_delete-fin-doc-from-card

&global-define edoc-proc_18                                      18

&global-define edoc-proc_18_batchwork-export_order_1              1
&global-define edoc-proc_18_batchwork-routing_order_2             2
&global-define edoc-proc_18_xml-esys-import_order_4               4
&global-define edoc-proc_18_xml-file-import_order_3               3
&global-define edoc-proc_18_batchwork-export_rcv
&global-define edoc-proc_18_batchwork-routing_rcv_6               6
&global-define edoc-proc_18_xml-esys-import_rcv_8                 8
&global-define edoc-proc_18_xml-file-import_rcv
&global-define edoc-proc_18_batchwork-routing_price-doc_10       10
&global-define edoc-proc_18_xml-esys-import_price-doc_12         12
&global-define edoc-proc_18_xml-esys-import_trn-doc_16           16
&global-define edoc-proc_18_batchwork-routing_trn-doc_14         14
&global-define edoc-proc_18_xml-esys-import_inv-doc_20           20
&global-define edoc-proc_18_xml-esys-import_contract_24          24
&global-define edoc-proc_18_batchwork-routing_intorder_26       26
&global-define edoc-proc_18_xml-esys-import_intorder
&global-define edoc-proc_18_batchwork-routing_inkas_30          30
&global-define edoc-proc_18_event_order_100                     100
&global-define edoc-proc_18_event_rcv_105                       105
&global-define edoc-proc_18_event_trn-doc_115                   115
&global-define edoc-proc_18_event_inv-doc
&global-define edoc-proc_18_event_intorder_125                  125
&global-define edoc-proc_18_event_price-doc_110                 110
&global-define edoc-proc_18_event_inkas_130                     130
&global-define edoc-proc_18_event_rvs-doc_135                   135
&global-define edoc-proc_18_event_shift_140                     140
&global-define edoc-proc_18_event_icnt-doc_145                  145
&global-define edoc-proc_18_event_fin-doc_150                   150
&global-define edoc-proc_18_event_fbr-doc_155                   155
&global-define edoc-proc_18_event_utd_160                       160
&global-define edoc-proc_18_event_mark_165                      165
&global-define edoc-proc_18_event_user-action_170               170
&global-define edoc-proc_18_text-export_specif_223              223
&global-define edoc-proc_18_text-import_specif_224              224
&global-define edoc-proc_18_excel-export_specif_225             225
&global-define edoc-proc_18_excel-import_specif_226             226


&global-define goods-proc_11                                    11

&global-define goods-proc_11_gds_5                           5
&global-define goods-proc_11_lcode_6                         6
&global-define goods-proc_11_prcode_7                        7
&global-define goods-proc_11_xml-file-import
&global-define goods-proc_11_xml-esys-import
&global-define goods-proc_11_batchwork-export
&global-define goods-proc_11_batchwork-routing_2                 2
&global-define goods-proc_11_rest-update
&global-define goods-proc_11_goods-cd-send
&global-define goods-proc_11_goods-batchwork


&global-define clients-proc_12                                    12

&global-define clients-proc_12_batchwork-export
&global-define clients-proc_12_batchwork-routing_2     2
&global-define clients-proc_12_xml-file-import
&global-define clients-proc_12_xml-esys-import
&global-define clients-proc_12_text-import
&global-define clients-proc_12_text-export
&global-define clients-proc_12_cli_6                    6

&global-define gds-grp-proc_13                                    13

&global-define cli-grp-proc_14                                    14

&global-define thref-proc_20                            20
&global-define thref-proc_20_batchwork-export
&global-define thref-proc_20_batchwork-routing_2        2
&global-define thref-proc_20_xml-file-import            3
&global-define thref-proc_20_xml-esys-import            4
&global-define thref-proc_20_rec_5                      5
&global-define thref-proc_20_ref-event_100              100


&global-define rep-proc_22                              22
&global-define rep-proc_22_batchwork_1                  1
&global-define rep-proc_22_batchwork_2                  2
&global-define rep-proc_22_batchwork_3                  3
&global-define rep-proc_22_batchwork_4                  4
&global-define rep-proc_22_close-shift_5                5
&global-define rep-proc_22_print-report_6               6

&global-define ord-proc_23                             23

&global-define fdoc-proc_24                             24
&global-define fdoc-proc_24_work_fin-doc_1              1


/* $Workfile$ e n d */