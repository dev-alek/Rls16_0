<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <xsl:processing-instruction name="mso-application">
      <xsl:text>progid="Excel.Sheet"</xsl:text>
    </xsl:processing-instruction>

    <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
      xmlns:o="urn:schemas-microsoft-com:office:office"
      xmlns:x="urn:schemas-microsoft-com:office:excel"
      xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
      xmlns:html="http://www.w3.org/TR/REC-html40">
      <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
        <Author>Кирюхин Сергей Сергеевич</Author>
        <LastAuthor>Кирюхин Сергей Сергеевич</LastAuthor>
        <Created>2012-08-03T13:10:47Z</Created>
        <LastSaved>2012-08-03T13:10:50Z</LastSaved>
        <Version>14.00</Version>
      </DocumentProperties>
      <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
        <AllowPNG/>
      </OfficeDocumentSettings>
      <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
        <WindowHeight>9255</WindowHeight>
        <WindowWidth>12390</WindowWidth>
        <WindowTopX>0</WindowTopX>
        <WindowTopY>1425</WindowTopY>
        <ProtectStructure>False</ProtectStructure>
        <ProtectWindows>False</ProtectWindows>
      </ExcelWorkbook>
      <Styles>
        <Style ss:ID="Default" ss:Name="Normal">
          <Alignment ss:Vertical="Bottom"/>
          <Borders/>
          <Font ss:FontName="Arial Cyr" x:CharSet="204"/>
          <Interior/>
          <NumberFormat/>
          <Protection/>
        </Style>
        <Style ss:ID="m32751616">
          <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
          </Borders>
          <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Bold="1"/>
          <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="s63">
          <Font ss:FontName="Times New Roman" x:CharSet="204" x:Family="Roman" ss:Size="9"/>
          <NumberFormat ss:Format="@"/>
        </Style>
        <Style ss:ID="s64">
          <Alignment ss:Vertical="Top"/>
          <Font ss:FontName="Calibri" x:CharSet="204" x:Family="Swiss" ss:Size="12"
            ss:Bold="1"/>
          </Style>
          <Style ss:ID="s65">
            <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Size="9"/>
            <NumberFormat ss:Format="@"/>
          </Style>
          <Style ss:ID="s66">
            <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
            <Borders>
              <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
            </Borders>
            <Font ss:FontName="Calibri" x:CharSet="204" x:Family="Swiss" ss:Size="11"
              ss:Bold="1"/>
              <Interior/>
            </Style>
            <Style ss:ID="s74"> <!-- right column of row -->
              <Alignment ss:Vertical="Bottom" ss:Indent="0"/>
              <Borders>
                <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
                <Border ss:Position="Right" ss:LineStyle="Continuous"/>
              </Borders>
              <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss"/>
              <Interior/>
              <NumberFormat ss:Format="#,##0.00_р_."/>
            </Style>
            <Style ss:ID="s75"> <!-- column of row -->
              <Alignment ss:Vertical="Bottom" ss:Indent="0"/>
              <Borders>
                <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
                <Border ss:Position="Left" ss:LineStyle="Continuous"/>
                <Border ss:Position="Right" ss:LineStyle="Continuous"/>
              </Borders>
              <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss"/>
              <Interior/>
              <NumberFormat ss:Format="#,##0.00_р_."/>
            </Style>
            <Style ss:ID="s76"> <!-- left column of row -->
              <Borders>
                <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
                <Border ss:Position="Left" ss:LineStyle="Continuous"/>
                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
              </Borders>
              <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss"/>
              <Interior/>
              <NumberFormat ss:Format="#,##0.00_р_."/>
            </Style>
            <!-- left column of subtotal -->
            <Style ss:ID="s82">
              <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:Indent="0"/>
              <Borders>
                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
                <Border ss:Position="Right" ss:LineStyle="Continuous"/>
                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
              </Borders>
              <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Bold="1"/>
              <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
              <NumberFormat ss:Format="#,##0.00_р_."/>
            </Style>
            <!-- column of subtotal -->
            <Style ss:ID="s83">
              <Alignment ss:Horizontal="Right" ss:Vertical="Bottom" ss:Indent="0" />
              <Borders>
                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
                <Border ss:Position="Left" ss:LineStyle="Continuous" />
                <Border ss:Position="Right" ss:LineStyle="Continuous" />
                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
              </Borders>
              <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Bold="1"/>
              <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
              <NumberFormat ss:Format="#,##0.00_р_."/>
            </Style>
            <!-- right column of subtotal -->
            <Style ss:ID="s84">
              <Alignment ss:Horizontal="Right" ss:Vertical="Bottom" ss:Indent="0"/>
              <Borders>
                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
              </Borders>
              <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Bold="1"/>
              <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
              <NumberFormat ss:Format="#,##0.00_р_."/>
            </Style>

          <Style ss:ID="s85"> <!-- right column of row -->
            <Alignment ss:Vertical="Bottom" ss:Indent="0"/>
            <Borders>
              <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
              <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Right" ss:LineStyle="Continuous"/>
            </Borders>
            <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss"/>
            <Interior/>
            <NumberFormat ss:Format="0.000"/>
          </Style>
          <Style ss:ID="s86"> <!-- column of row -->
            <Alignment ss:Vertical="Bottom" ss:Indent="0"/>
            <Borders>
              <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
              <Border ss:Position="Left" ss:LineStyle="Continuous"/>
              <Border ss:Position="Right" ss:LineStyle="Continuous"/>
            </Borders>
            <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss"/>
            <Interior/>
            <NumberFormat ss:Format="0.000"/>
          </Style>
          <Style ss:ID="s87"> <!-- left column of row -->
            <Borders>
              <Border ss:Position="Bottom" ss:LineStyle="Continuous"/>
              <Border ss:Position="Left" ss:LineStyle="Continuous"/>
              <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
            </Borders>
            <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss"/>
            <Interior/>
            <NumberFormat ss:Format="0.000"/>
          </Style>
          <!-- left column of subtotal -->
          <Style ss:ID="s88">
            <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:Indent="0"/>
            <Borders>
              <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Right" ss:LineStyle="Continuous"/>
              <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
            </Borders>
            <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Bold="1"/>
            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
            <NumberFormat ss:Format="0.000"/>
          </Style>
          <!-- column of subtotal -->
          <Style ss:ID="s89">
            <Alignment ss:Horizontal="Right" ss:Vertical="Bottom" ss:Indent="0" />
            <Borders>
              <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Left" ss:LineStyle="Continuous" />
              <Border ss:Position="Right" ss:LineStyle="Continuous" />
              <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
            </Borders>
            <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Bold="1"/>
            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
            <NumberFormat ss:Format="0.000"/>
          </Style>
          <!-- right column of subtotal -->
          <Style ss:ID="s90">
            <Alignment ss:Horizontal="Right" ss:Vertical="Bottom" ss:Indent="0"/>
            <Borders>
              <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"/>
              <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
            </Borders>
            <Font ss:FontName="Arial" x:CharSet="204" x:Family="Swiss" ss:Bold="1"/>
            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>
            <NumberFormat ss:Format="0.000"/>
          </Style>
        </Styles>


        <!-- Worksheet -->

        <xsl:for-each select="Workbook/Worksheet">

          <Worksheet>
            <xsl:attribute name="ss:Name">
              <xsl:value-of select="./@Name" />
            </xsl:attribute>

            <Table x:FullColumns="1" x:FullRows="1">

              <xsl:for-each select="./table/columns/*">

                <Column ss:AutoFitWidth="0">
                  <xsl:attribute name="ss:Width">
                    <xsl:value-of select="." />
                  </xsl:attribute>
                </Column>

              </xsl:for-each>

              <!-- Header -->

              <xsl:for-each select="./header/row">

                <Row ss:AutoFitHeight="0" ss:Height="15.75" ss:StyleID="s63">
                  <Cell ss:StyleID="s64"><Data ss:Type="String"><xsl:value-of select="."/></Data></Cell>
                </Row>

              </xsl:for-each>

              <!-- Table-Header -->

              <Row ss:AutoFitHeight="0" ss:StyleID="s65">
                <xsl:attribute name="ss:Height">
                  <xsl:value-of select="./table/table-header/@Height" />
                </xsl:attribute>
                <xsl:for-each select="./table/table-header/header">
                  <Cell ss:StyleID="s66"><Data ss:Type="String"><xsl:value-of select="."/></Data></Cell>
                </xsl:for-each>
              </Row>

              <!-- Table-Body -->

              <xsl:for-each select="./table/row">

                <xsl:choose>
                  <!-- group -->
                  <xsl:when test="@Type='group'">

                    <Row ss:AutoFitHeight="0" ss:Height="13.5" ss:StyleID="s63">
                      <Cell ss:StyleID="m32751616">
                        <xsl:attribute name="ss:MergeAcross">
                          <xsl:value-of select="Merge"/>
                        </xsl:attribute>
                        <Data ss:Type="String"><xsl:value-of select="Name"/></Data>
                      </Cell>
                    </Row>

                  </xsl:when>
                  <!-- subtotal -->
                  <xsl:when test="@Type='subtotal'">

                    <Row ss:AutoFitHeight="0" ss:Height="13.5" ss:StyleID="s63">

                      <xsl:for-each select="cell">

                        <xsl:choose>

                          <xsl:when test="position()=1">
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s88"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s82"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>

                          <xsl:when test="position()=last()">
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s90"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s84"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>

                          <xsl:otherwise>
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s89"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s83"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:otherwise>

                        </xsl:choose>
                      </xsl:for-each>

                    </Row>

                  </xsl:when>
                  <!-- total -->
                  <xsl:when test="@Type='total'">

                    <Row ss:AutoFitHeight="0" ss:Height="13.5" ss:StyleID="s63">

                      <xsl:for-each select="cell">
                        <xsl:choose>

                          <xsl:when test="position()=1">
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s88"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s82"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>

                          <xsl:when test="position()=last()">
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s90"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s84"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>

                          <xsl:otherwise>
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s89"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s83"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:otherwise>

                        </xsl:choose>
                      </xsl:for-each>

                    </Row>

                  </xsl:when>
                  <!-- row -->
                  <xsl:otherwise>

                    <Row ss:AutoFitHeight="0" ss:Height="13.5" ss:StyleID="s63">

                      <xsl:for-each select="cell">
                        <xsl:choose>

                          <xsl:when test="position()=1">
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s85"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s74"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>

                          <xsl:when test="position()=last()">
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s87"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s76"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>

                          <xsl:otherwise>
                            <xsl:choose>
                              <xsl:when test="@Type='Qnty'">
                                <Cell ss:StyleID="s86"><Data>
                                  <xsl:attribute name="ss:Type">Number</xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:when>
                              <xsl:otherwise>
                                <Cell ss:StyleID="s75"><Data>
                                  <xsl:attribute name="ss:Type">
                                    <xsl:value-of select="./@Type"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </Data></Cell>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:otherwise>

                        </xsl:choose>
                      </xsl:for-each>

                    </Row>

                  </xsl:otherwise>

                </xsl:choose>
              </xsl:for-each>
              
              <xsl:for-each select="./footer/row">

			    <Row ss:AutoFitHeight="0" ss:Height="15.75" ss:StyleID="s63">
			    <Cell ss:StyleID="s64"><Data ss:Type="String"><xsl:value-of select="."/></Data></Cell>
			    </Row>

			   </xsl:for-each>
            </Table>
            <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
              <PageSetup>
                <Layout x:Orientation="Landscape"/>
                <Header x:Margin="0.3"/>
                <Footer x:Margin="0.3"/>
                <PageMargins x:Bottom="0.75" x:Left="0.25" x:Right="0.25" x:Top="0.75"/>
              </PageSetup>
              <Print>
                <ValidPrinterInfo/>
                <PaperSizeIndex>9</PaperSizeIndex>
                <HorizontalResolution>600</HorizontalResolution>
                <VerticalResolution>600</VerticalResolution>
              </Print>
              <Selected/>
              <ProtectObjects>False</ProtectObjects>
              <ProtectScenarios>False</ProtectScenarios>
            </WorksheetOptions>
          </Worksheet>

        </xsl:for-each>
      </Workbook>

    </xsl:template>
  </xsl:stylesheet>