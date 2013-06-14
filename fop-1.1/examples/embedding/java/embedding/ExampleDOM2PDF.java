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

/* $Id: ExampleDOM2PDF.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package embedding;

// Java
import java.io.File;
import java.io.OutputStream;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.ParserConfigurationException;

//JAXP
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Source;
import javax.xml.transform.Result;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXResult;

// DOM
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.Text;

// FOP
import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;


/**
 * This class demonstrates the conversion of a DOM Document to PDF
 * using JAXP (XSLT) and FOP (XSL-FO).
 */
public class ExampleDOM2PDF {

    // configure fopFactory as desired
    private FopFactory fopFactory = FopFactory.newInstance();

    /** xsl-fo namespace URI */
    protected static String foNS = "http://www.w3.org/1999/XSL/Format";

    /**
     * Converts a DOM Document to a PDF file using FOP.
     * @param xslfoDoc the DOM Document
     * @param pdf the target PDF file
     */
    public void convertDOM2PDF(Document xslfoDoc, File pdf) {
        try {
            FOUserAgent foUserAgent = fopFactory.newFOUserAgent();
            // configure foUserAgent as desired

            // Setup output
            OutputStream out = new java.io.FileOutputStream(pdf);
            out = new java.io.BufferedOutputStream(out);

            try {
                // Construct fop with desired output format and output stream
                Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, foUserAgent, out);

                // Setup Identity Transformer
                TransformerFactory factory = TransformerFactory.newInstance();
                Transformer transformer = factory.newTransformer(); // identity transformer

                // Setup input for XSLT transformation
                Source src = new DOMSource(xslfoDoc);

                // Resulting SAX events (the generated FO) must be piped through to FOP
                Result res = new SAXResult(fop.getDefaultHandler());

                // Start XSLT transformation and FOP processing
                transformer.transform(src, res);
            } finally {
                out.close();
            }

        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }

    }

    /**
     * Main method.
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        try {
            System.out.println("FOP ExampleDOM2PDF\n");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            outDir.mkdirs();

            //Setup output file
            File pdffile = new File(outDir, "ResultDOM2PDF.pdf");
            System.out.println("PDF Output File: " + pdffile);
            System.out.println();

            Document foDoc = buildDOMDocument();

            ExampleDOM2PDF app = new ExampleDOM2PDF();
            app.convertDOM2PDF(foDoc, pdffile);

            System.out.println("Success!");

        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }
    }

    /**
     * Builds the example FO document as a DOM in memory.
     * @return the FO document
     * @throws ParserConfigurationException In case there is a problem creating a DOM document
     */
    private static Document buildDOMDocument() throws ParserConfigurationException {
        // Create a sample XSL-FO DOM document
        Document foDoc = null;
        Element root = null, ele1 = null, ele2 = null, ele3 = null;

        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder db = dbf.newDocumentBuilder();
        foDoc = db.newDocument();

        root = foDoc.createElementNS(foNS, "fo:root");
        foDoc.appendChild(root);

        ele1 = foDoc.createElementNS(foNS, "fo:layout-master-set");
        root.appendChild(ele1);
        ele2 = foDoc.createElementNS(foNS, "fo:simple-page-master");
        ele1.appendChild(ele2);
        ele2.setAttributeNS(null, "master-name", "letter");
        ele2.setAttributeNS(null, "page-height", "11in");
        ele2.setAttributeNS(null, "page-width", "8.5in");
        ele2.setAttributeNS(null, "margin-top", "1in");
        ele2.setAttributeNS(null, "margin-bottom", "1in");
        ele2.setAttributeNS(null, "margin-left", "1in");
        ele2.setAttributeNS(null, "margin-right", "1in");
        ele3 = foDoc.createElementNS(foNS, "fo:region-body");
        ele2.appendChild(ele3);
        ele1 = foDoc.createElementNS(foNS, "fo:page-sequence");
        root.appendChild(ele1);
        ele1.setAttributeNS(null, "master-reference", "letter");
        ele2 = foDoc.createElementNS(foNS, "fo:flow");
        ele1.appendChild(ele2);
        ele2.setAttributeNS(null, "flow-name", "xsl-region-body");
        addElement(ele2, "fo:block", "Hello World!");
        return foDoc;
    }

    /**
     * Adds an element to the DOM.
     * @param parent parent node to attach the new element to
     * @param newNodeName name of the new node
     * @param textVal content of the element
     */
    protected static void addElement(Node parent, String newNodeName,
                                String textVal) {
        if (textVal == null) {
            return;
        }  // use only with text nodes
        Element newElement = parent.getOwnerDocument().createElementNS(
                                        foNS, newNodeName);
        Text elementText = parent.getOwnerDocument().createTextNode(textVal);
        newElement.appendChild(elementText);
        parent.appendChild(newElement);
    }
}

