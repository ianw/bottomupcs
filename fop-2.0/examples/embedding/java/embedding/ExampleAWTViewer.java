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

/* $Id: ExampleAWTViewer.java 1356646 2012-07-03 09:46:41Z mehdi $ */

package embedding;

//Java
import java.io.File;
import java.io.IOException;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.avalon.framework.ExceptionUtil;

import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;

/**
 * This class demonstrates the use of the AWT Viewer.
 */
public class ExampleAWTViewer {

    // configure fopFactory as desired
    private final FopFactory fopFactory = FopFactory.newInstance(new File(".").toURI());

    /**
     * Display an FO file in the AWT Preview.
     * @param fo the FO file
     * @throws IOException In case of an I/O problem
     * @throws FOPException In case of a problem during layout
     * @throws TransformerException In case of a problem during XML processing
     */
    public void viewFO(File fo)
                throws IOException, FOPException, TransformerException {

        //Setup FOP
        Fop fop = fopFactory.newFop(MimeConstants.MIME_FOP_AWT_PREVIEW);

        try {

            //Load XSL-FO file (you can also do an XSL transformation here)
            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer();
            Source src = new StreamSource(fo);
            Result res = new SAXResult(fop.getDefaultHandler());
            transformer.transform(src, res);

        } catch (Exception e) {
            if (e instanceof FOPException) {
                throw (FOPException)e;
            }
            throw new FOPException(e);
        }
    }

    /**
     * Main method.
     * @param args the command-line arguments
     */
    public static void main(String[] args) {
        try {
            System.out.println("FOP ExampleAWTViewer\n");
            System.out.println("Preparing...");

            //Setup directories
            File baseDir = new File(".");
            File outDir = new File(baseDir, "out");
            outDir.mkdirs();

            //Setup input and output files
            File fofile = new File(baseDir, "xml/fo/helloworld.fo");

            System.out.println("Input: XSL-FO (" + fofile + ")");
            System.out.println("Output: AWT Viewer");
            System.out.println();
            System.out.println("Starting AWT Viewer...");

            ExampleAWTViewer app = new ExampleAWTViewer();
            app.viewFO(fofile);

            System.out.println("Success!");
        } catch (Exception e) {
            System.err.println(ExceptionUtil.printStackTrace(e));
            System.exit(-1);
        }
    }
}
