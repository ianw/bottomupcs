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

/* $Id: ExampleStamp.java 830257 2009-10-27 17:37:14Z vhennebert $ */

package embedding.atxml;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.xml.sax.SAXException;

import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;
import org.apache.fop.area.AreaTreeModel;
import org.apache.fop.area.AreaTreeParser;
import org.apache.fop.area.RenderPagesModel;
import org.apache.fop.fonts.FontInfo;

import embedding.ExampleObj2XML;
import embedding.model.ProjectTeam;

/**
 * Example for the area tree XML format that demonstrates the stamping of a document with some
 * kind of watermark. The resulting document is then rendered to a PDF file.
 */
public class ExampleStamp {

    // configure fopFactory as desired
    private FopFactory fopFactory = FopFactory.newInstance();

    /**
     * Stamps an area tree XML file and renders it to a PDF file.
     * @param atfile the area tree XML file
     * @param stampSheet the stylesheet that does the stamping
     * @param pdffile the target PDF file
     * @throws IOException In case of an I/O problem
     * @throws TransformerException In case of a XSL transformation problem
     * @throws SAXException In case of an XML-related problem
     */
    public void stampToPDF(File atfile, File stampSheet, File pdffile)
            throws IOException, TransformerException, SAXException {
        // Setup output
        OutputStream out = new java.io.FileOutputStream(pdffile);
        out = new java.io.BufferedOutputStream(out);
        try {
            //Setup fonts and user agent
            FontInfo fontInfo = new FontInfo();
            FOUserAgent userAgent = fopFactory.newFOUserAgent();

            //Construct the AreaTreeModel that will received the individual pages
            AreaTreeModel treeModel = new RenderPagesModel(userAgent,
                    MimeConstants.MIME_PDF, fontInfo, out);

            //Iterate over all area tree files
            AreaTreeParser parser = new AreaTreeParser();
            Source src = new StreamSource(atfile);
            Source xslt = new StreamSource(stampSheet);

            //Setup Transformer for XSLT processing
            TransformerFactory tFactory = TransformerFactory.newInstance();
            Transformer transformer = tFactory.newTransformer(xslt);

            //Send XSLT result to AreaTreeParser
            SAXResult res = new SAXResult(parser.getContentHandler(treeModel, userAgent));

            //Start XSLT transformation and area tree parsing
            transformer.transform(src, res);

            //Signal the end of the processing. The renderer can finalize the target document.
            treeModel.endDocument();
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
            System.out.println("FOP ExampleConcat\n");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            outDir.mkdirs();

            //Setup output file
            File xsltfile = new File(baseDir, "xml/xslt/projectteam2fo.xsl");
            File atfile = new File(outDir, "team.at.xml");
            File stampxsltfile = new File(baseDir, "xml/xslt/atstamp.xsl");
            File pdffile = new File(outDir, "ResultStamped.pdf");
            System.out.println("Area Tree XML file : " + atfile.getCanonicalPath());
            System.out.println("Stamp XSLT: " + stampxsltfile.getCanonicalPath());
            System.out.println("PDF Output File: " + pdffile.getCanonicalPath());
            System.out.println();

            ProjectTeam team1 = ExampleObj2XML.createSampleProjectTeam();

            //Create area tree XML file
            ExampleConcat concatapp = new ExampleConcat();
            concatapp.convertToAreaTreeXML(
                    team1.getSourceForProjectTeam(),
                    new StreamSource(xsltfile), atfile);

            //Stamp document and produce a PDF from the area tree XML format
            ExampleStamp app = new ExampleStamp();
            app.stampToPDF(atfile, stampxsltfile, pdffile);

            System.out.println("Success!");

        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }
    }

}
