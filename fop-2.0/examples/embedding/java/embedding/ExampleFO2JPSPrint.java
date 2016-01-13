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

/* $Id: ExampleFO2JPSPrint.java 1356646 2012-07-03 09:46:41Z mehdi $ */

package embedding;

// Java
import java.io.File;
import java.io.IOException;

import javax.print.Doc;
import javax.print.DocFlavor;
import javax.print.DocPrintJob;
import javax.print.PrintException;
import javax.print.PrintService;
import javax.print.PrintServiceLookup;
import javax.print.ServiceUI;
import javax.print.SimpleDoc;
import javax.print.attribute.HashPrintRequestAttributeSet;
import javax.print.attribute.PrintRequestAttributeSet;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.render.print.PageableRenderer;

/**
 * This class demonstrates printing an FO file using JPS (Java Printing System).
 */
public class ExampleFO2JPSPrint {

    // configure fopFactory as desired
    private final FopFactory fopFactory = FopFactory.newInstance(new File(".").toURI());

    private DocPrintJob createDocPrintJob() {
        PrintService[] services = PrintServiceLookup.lookupPrintServices(
                DocFlavor.SERVICE_FORMATTED.PAGEABLE, null);
        PrintRequestAttributeSet attributes = new HashPrintRequestAttributeSet();
        PrintService printService = ServiceUI.printDialog(null, 50, 50,
                services, services[0], null, attributes);
        if (printService != null) {
            return printService.createPrintJob();
        } else {
            return null;
        }
    }

    /**
     * Prints an FO file using JPS.
     * @param fo the FO file
     * @throws IOException In case of an I/O problem
     * @throws FOPException In case of a FOP problem
     * @throws TransformerException In case of a problem during XSLT processing
     * @throws PrintException If an error occurs while printing
     */
    public void printFO(File fo)
            throws IOException, FOPException, TransformerException, PrintException {

        //Set up DocPrintJob instance
        DocPrintJob printJob = createDocPrintJob();

        //Set up a custom user agent so we can supply our own renderer instance
        FOUserAgent userAgent = fopFactory.newFOUserAgent();

        PageableRenderer renderer = new PageableRenderer(userAgent);
        userAgent.setRendererOverride(renderer);

        // Construct FOP with desired output format
        Fop fop = fopFactory.newFop(userAgent);

        // Setup JAXP using identity transformer
        TransformerFactory factory = TransformerFactory.newInstance();
        Transformer transformer = factory.newTransformer(); // identity transformer

        // Setup input stream
        Source src = new StreamSource(fo);

        // Resulting SAX events (the generated FO) must be piped through to FOP
        Result res = new SAXResult(fop.getDefaultHandler());

        // Start XSLT transformation and FOP processing
        transformer.transform(src, res);

        Doc doc = new SimpleDoc(renderer, DocFlavor.SERVICE_FORMATTED.PAGEABLE, null);
        printJob.print(doc, null);
    }

    /**
     * Main method.
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        try {
            System.out.println("FOP ExampleFO2JPSPrint\n");
            System.out.println("Preparing...");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            outDir.mkdirs();

            //Setup input and output files
            File fofile = new File(baseDir, "xml/fo/helloworld.fo");

            System.out.println("Input: XSL-FO (" + fofile + ")");
            System.out.println("Output: JPS (Java Printing System)");
            System.out.println();
            System.out.println("Transforming...");

            ExampleFO2JPSPrint app = new ExampleFO2JPSPrint();
            app.printFO(fofile);

            System.out.println("Success!");
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }
    }
}
