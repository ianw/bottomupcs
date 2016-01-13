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

/* $Id: ExampleFO2OldStylePrint.java 1356646 2012-07-03 09:46:41Z mehdi $ */

package embedding;

// Java
import java.awt.print.PrinterJob;
import java.io.File;
import java.io.IOException;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;

/**
 * This class demonstrates printing an FO file to a PrinterJob instance.
 */
public class ExampleFO2OldStylePrint {

    // configure fopFactory as desired
    private final FopFactory fopFactory = FopFactory.newInstance(new File(".").toURI());

    /**
     * Prints an FO file using an old-style PrinterJob.
     * @param fo the FO file
     * @throws IOException In case of an I/O problem
     * @throws FOPException In case of a FOP problem
     */
    public void printFO(File fo) throws IOException, FOPException {

        //Set up PrinterJob instance
        PrinterJob printerJob = PrinterJob.getPrinterJob();
        printerJob.setJobName("FOP Printing Example");

        try {
            //Set up a custom user agent so we can supply our own renderer instance
            FOUserAgent userAgent = fopFactory.newFOUserAgent();
            userAgent.getRendererOptions().put("printerjob", printerJob);

            // Construct FOP with desired output format
            Fop fop = fopFactory.newFop(MimeConstants.MIME_FOP_PRINT, userAgent);

            // Setup JAXP using identity transformer
            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer(); // identity transformer

            // Setup input stream
            Source src = new StreamSource(fo);

            // Resulting SAX events (the generated FO) must be piped through to FOP
            Result res = new SAXResult(fop.getDefaultHandler());

            // Start XSLT transformation and FOP processing
            transformer.transform(src, res);

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
            System.out.println("FOP ExampleFO2OldStylePrint\n");
            System.out.println("Preparing...");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            outDir.mkdirs();

            //Setup input and output files
            File fofile = new File(baseDir, "xml/fo/helloworld.fo");

            System.out.println("Input: XSL-FO (" + fofile + ")");
            System.out.println("Output: old-style printing using PrinterJob");
            System.out.println();
            System.out.println("Transforming...");

            ExampleFO2OldStylePrint app = new ExampleFO2OldStylePrint();
            app.printFO(fofile);

            System.out.println("Success!");
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(-1);
        }
    }
}
