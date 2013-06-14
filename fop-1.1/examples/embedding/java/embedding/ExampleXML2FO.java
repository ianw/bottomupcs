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

/* $Id: ExampleXML2FO.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package embedding;

//Java
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

//JAXP
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerException;
import javax.xml.transform.Source;
import javax.xml.transform.Result;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

/**
 * This class demonstrates the conversion of an XML file to an XSL-FO file
 * using JAXP (XSLT).
 */
public class ExampleXML2FO {

    /**
     * Converts an XML file to an XSL-FO file using JAXP (XSLT).
     * @param xml the XML file
     * @param xslt the stylesheet file
     * @param fo the target XSL-FO file
     * @throws IOException In case of an I/O problem
     * @throws TransformerException In case of a XSL transformation problem
     */
    public void convertXML2FO(File xml, File xslt, File fo)
                throws IOException, TransformerException {

        //Setup output
        OutputStream out = new java.io.FileOutputStream(fo);
        try {
            //Setup XSLT
            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer(new StreamSource(xslt));

            //Setup input for XSLT transformation
            Source src = new StreamSource(xml);

            //Resulting SAX events (the generated FO) must be piped through to FOP
            Result res = new StreamResult(out);

            //Start XSLT transformation and FOP processing
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
            System.out.println("FOP ExampleXML2FO\n");
            System.out.println("Preparing...");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            outDir.mkdirs();

            //Setup input and output files
            File xmlfile = new File(baseDir, "xml/xml/projectteam.xml");
            File xsltfile = new File(baseDir, "xml/xslt/projectteam2fo.xsl");
            File fofile = new File(outDir, "ResultXML2FO.fo");

            System.out.println("Input: XML (" + xmlfile + ")");
            System.out.println("Stylesheet: " + xsltfile);
            System.out.println("Output: XSL-FO (" + fofile + ")");
            System.out.println();
            System.out.println("Transforming...");

            ExampleXML2FO app = new ExampleXML2FO();
            app.convertXML2FO(xmlfile, xsltfile, fofile);

            System.out.println("Success!");
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }
    }
}
