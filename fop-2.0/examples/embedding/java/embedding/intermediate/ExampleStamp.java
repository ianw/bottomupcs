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

/* $Id: ExampleStamp.java 1356646 2012-07-03 09:46:41Z mehdi $ */

package embedding.intermediate;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.xml.sax.SAXException;

import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;
import org.apache.fop.render.intermediate.IFDocumentHandler;
import org.apache.fop.render.intermediate.IFException;
import org.apache.fop.render.intermediate.IFParser;
import org.apache.fop.render.intermediate.IFUtil;

import embedding.ExampleObj2XML;
import embedding.model.ProjectTeam;

/**
 * Example for the intermediate format that demonstrates the stamping of a document with some
 * kind of watermark. The resulting document is then rendered to a PDF file.
 */
public class ExampleStamp {

    // configure fopFactory as desired
    private final FopFactory fopFactory = FopFactory.newInstance(new File(".").toURI());

    /**
     * Stamps an intermediate file and renders it to a PDF file.
     * @param iffile the intermediate file (area tree XML)
     * @param stampSheet the stylesheet that does the stamping
     * @param pdffile the target PDF file
     * @throws IOException In case of an I/O problem
     * @throws TransformerException In case of a XSL transformation problem
     * @throws SAXException In case of an XML-related problem
     * @throws IFException if there was an IF-related error while creating the output file
     */
    public void stampToPDF(File iffile, File stampSheet, File pdffile)
            throws IOException, TransformerException, SAXException, IFException {
        // Setup output
        OutputStream out = new java.io.FileOutputStream(pdffile);
        out = new java.io.BufferedOutputStream(out);
        try {
            //user agent
            FOUserAgent userAgent = fopFactory.newFOUserAgent();

            //Setup target handler
            String mime = MimeConstants.MIME_PDF;
            IFDocumentHandler targetHandler = fopFactory.getRendererFactory().createDocumentHandler(
                    userAgent, mime);

            //Setup fonts
            IFUtil.setupFonts(targetHandler);
            targetHandler.setResult(new StreamResult(pdffile));

            IFParser parser = new IFParser();

            Source src = new StreamSource(iffile);
            Source xslt = new StreamSource(stampSheet);

            //Setup Transformer for XSLT processing
            TransformerFactory tFactory = TransformerFactory.newInstance();
            Transformer transformer = tFactory.newTransformer(xslt);

            //Send XSLT result to AreaTreeParser
            SAXResult res = new SAXResult(parser.getContentHandler(targetHandler, userAgent));

            //Start XSLT transformation and area tree parsing
            transformer.transform(src, res);
        } finally {
            out.close();
        }
    }

    /**
     * Main method.
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        try {
            System.out.println("FOP ExampleConcat (for the Intermediate Format)\n");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            outDir.mkdirs();

            //Setup output file
            File xsltfile = new File(baseDir, "xml/xslt/projectteam2fo.xsl");
            File iffile = new File(outDir, "team.if.xml");
            File stampxsltfile = new File(baseDir, "xml/xslt/ifstamp.xsl");
            File pdffile = new File(outDir, "ResultIFStamped.pdf");
            System.out.println("Intermediate file : " + iffile.getCanonicalPath());
            System.out.println("Stamp XSLT: " + stampxsltfile.getCanonicalPath());
            System.out.println("PDF Output File: " + pdffile.getCanonicalPath());
            System.out.println();

            ProjectTeam team1 = ExampleObj2XML.createSampleProjectTeam();

            //Create intermediate file
            ExampleConcat concatapp = new ExampleConcat();
            concatapp.convertToIntermediate(
                    team1.getSourceForProjectTeam(),
                    new StreamSource(xsltfile), iffile);

            //Stamp document and produce a PDF from the intermediate format
            ExampleStamp app = new ExampleStamp();
            app.stampToPDF(iffile, stampxsltfile, pdffile);

            System.out.println("Success!");

        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }
    }

}
