/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* $Id: ExampleJava2D2PDF.java 1296385 2012-03-02 19:02:16Z gadams $ */

package embedding;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics2D;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.StringReader;

import javax.swing.JEditorPane;

import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;
import org.apache.avalon.framework.configuration.DefaultConfiguration;
import org.apache.commons.io.IOUtils;

import org.apache.xmlgraphics.util.UnitConv;

import org.apache.fop.svg.PDFDocumentGraphics2D;
import org.apache.fop.svg.PDFDocumentGraphics2DConfigurator;

/**
 * This example class demonstrates the use of {@link PDFDocumentGraphics2D} that can be
 * used to create a PDF file from Java2D graphics (using the {@link Graphics2D} API).
 */
public class ExampleJava2D2PDF {

    private Configuration createAutoFontsConfiguration() {
        //Create a default configuration using auto-detection of fonts.
        //This can be a bit slow but covers most use cases.
        DefaultConfiguration c = new DefaultConfiguration("cfg");
        DefaultConfiguration fonts = new DefaultConfiguration("fonts");
        c.addChild(fonts);
        DefaultConfiguration autodetect = new DefaultConfiguration("auto-detect");
        fonts.addChild(autodetect);
        return c;

        /* You can also load the configuration from a file:
        DefaultConfigurationBuilder cfgBuilder = new DefaultConfigurationBuilder();
        return cfgBuilder.buildFromFile(configFile);
        */
    }

    private void configure(PDFDocumentGraphics2D g2d, Configuration cfg)
                throws ConfigurationException {

        PDFDocumentGraphics2DConfigurator configurator = new PDFDocumentGraphics2DConfigurator();
        boolean useComplexScriptFeatures = false;
        configurator.configure(g2d, cfg, useComplexScriptFeatures);
    }

    /**
     * Creates a PDF file. The contents are painted using a Graphics2D implementation that
     * generates an PDF file.
     * @param outputFile the target file
     * @throws IOException In case of an I/O error
     * @throws ConfigurationException if an error occurs configuring the PDF output
     */
    public void generatePDF(File outputFile) throws IOException, ConfigurationException {
        OutputStream out = new java.io.FileOutputStream(outputFile);
        out = new java.io.BufferedOutputStream(out);
        try {

            //Instantiate the PDFDocumentGraphics2D instance
            PDFDocumentGraphics2D g2d = new PDFDocumentGraphics2D(false);
            g2d.setGraphicContext(new org.apache.xmlgraphics.java2d.GraphicContext());

            //Configure the G2D with the necessary fonts
            configure(g2d, createAutoFontsConfiguration());

            //Set up the document size
            Dimension pageSize = new Dimension(
                    (int)Math.ceil(UnitConv.mm2pt(210)),
                    (int)Math.ceil(UnitConv.mm2pt(297))); //page size A4 (in pt)
            g2d.setupDocument(out, pageSize.width, pageSize.height);
            g2d.translate(144, 72); //Establish some page borders

            //A few rectangles rotated and with different color
            Graphics2D copy = (Graphics2D)g2d.create();
            int c = 12;
            for (int i = 0; i < c; i++) {
                float f = ((i + 1) / (float)c);
                Color col = new Color(0.0f, 1 - f, 0.0f);
                copy.setColor(col);
                copy.fillRect(70, 90, 50, 50);
                copy.rotate(-2 * Math.PI / c, 70, 90);
            }
            copy.dispose();

            //Some text
            g2d.rotate(-0.25);
            g2d.setColor(Color.RED);
            g2d.setFont(new Font("sans-serif", Font.PLAIN, 36));
            g2d.drawString("Hello world!", 140, 140);
            g2d.setColor(Color.RED.darker());
            g2d.setFont(new Font("serif", Font.PLAIN, 36));
            g2d.drawString("Hello world!", 140, 180);

            pageSize = new Dimension(pageSize.height, pageSize.width);
            g2d.nextPage(pageSize.width, pageSize.height);

            //Demonstrate painting rich text
            String someHTML = "<html><body style=\"font-family:Verdana\">"
                + "<p>Welcome to <b>page 2!</b></p>"
                + "<h2>PDFDocumentGraphics2D Demonstration</h2>"
                + "<p>We can <i>easily</i> paint some HTML here!</p>"
                + "<p style=\"color:green;\">"
                + "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin accumsan"
                + " condimentum ullamcorper. Sed varius quam id arcu fermentum luctus. Praesent"
                + " nisi ligula, cursus sed vestibulum vel, sodales sed lectus.</p>"
                + "</body></html>";
            JEditorPane htmlComp = new JEditorPane();
            htmlComp.setContentType("text/html");
            htmlComp.read(new StringReader(someHTML), null);
            htmlComp.setSize(new Dimension(pageSize.width - 72, pageSize.height - 72));
            //htmlComp.setBackground(Color.ORANGE);
            htmlComp.validate();
            htmlComp.printAll(g2d);

            //Cleanup
            g2d.finish();
        } finally {
            IOUtils.closeQuietly(out);
        }
    }

    /**
     * Main method.
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        try {
            System.out.println("FOP " + ExampleJava2D2PDF.class.getSimpleName() + "\n");
            System.out.println("Preparing...");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            if (!outDir.isDirectory()) {
                if (!outDir.mkdirs()) {
                    throw new IOException("Could not create output directory: " + outDir);
                }
            }

            //Setup output file
            File pdffile = new File(outDir, "ResultJava2D2PDF.pdf");

            System.out.println("Output: PDF (" + pdffile + ")");
            System.out.println();
            System.out.println("Generating...");

            ExampleJava2D2PDF app = new ExampleJava2D2PDF();
            app.generatePDF(pdffile);

            System.out.println("Success!");
        } catch (Throwable t) {
            t.printStackTrace(System.err);
            System.exit(-1);
        }
    }
}
