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

/* $Id: PreloaderPlan.java 1391016 2012-09-27 14:00:16Z mehdi $ */

package org.apache.fop.plan;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.stream.StreamSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.apache.xmlgraphics.image.loader.Image;
import org.apache.xmlgraphics.image.loader.ImageContext;
import org.apache.xmlgraphics.image.loader.ImageInfo;
import org.apache.xmlgraphics.image.loader.ImageSize;
import org.apache.xmlgraphics.image.loader.impl.AbstractImagePreloader;
import org.apache.xmlgraphics.image.loader.impl.ImageXMLDOM;
import org.apache.xmlgraphics.image.loader.util.ImageUtil;
import org.apache.xmlgraphics.io.XmlSourceUtil;

import org.apache.fop.util.DefaultErrorListener;
import org.apache.fop.util.UnclosableInputStream;

/**
 * Image preloader for Plan images.
 */
public class PreloaderPlan extends AbstractImagePreloader {

    /** Logger instance */
    private static Log log = LogFactory.getLog(PreloaderPlan.class);

    /** {@inheritDoc} */
    public ImageInfo preloadImage(String uri, Source src, ImageContext context)
            throws IOException {
        if (!ImageUtil.hasInputStream(src)) {
            //TODO Remove this and support DOMSource and possibly SAXSource
            return null;
        }
        ImageInfo info = getImage(uri, src, context);
        if (info != null) {
            ImageUtil.closeQuietly(src); //Image is fully read
        }
        return info;
    }

    private ImageInfo getImage(String uri, Source src, ImageContext context) throws IOException {

        InputStream in = new UnclosableInputStream(ImageUtil.needInputStream(src));
        try {
            Document planDoc = getDocument(in);
            Element rootEl = planDoc.getDocumentElement();
            if (!PlanElementMapping.NAMESPACE.equals(
                    rootEl.getNamespaceURI())) {
                in.reset();
                return null;
            }

            //Have to render the plan to know its size
            PlanRenderer pr = new PlanRenderer();
            Document svgDoc = pr.createSVGDocument(planDoc);
            float width = pr.getWidth();
            float height = pr.getHeight();

            //Return converted SVG image
            ImageInfo info = new ImageInfo(uri, "image/svg+xml");
            final ImageSize size = new ImageSize();
            size.setSizeInMillipoints(
                    Math.round(width * 1000),
                    Math.round(height * 1000));
            //Set the resolution to that of the FOUserAgent
            size.setResolution(context.getSourceResolution());
            size.calcPixelsFromSize();
            info.setSize(size);

            //The whole image had to be loaded for this, so keep it
            Image image = new ImageXMLDOM(info, svgDoc,
                    svgDoc.getDocumentElement().getNamespaceURI());
            info.getCustomObjects().put(ImageInfo.ORIGINAL_IMAGE, image);

            return info;
        } catch (TransformerException e) {
            try {
                in.reset();
            } catch (IOException ioe) {
                // we're more interested in the original exception
            }
            log.debug("Error while trying to parsing a Plan file: "
                    + e.getMessage());
            return null;
        }
    }

    private Document getDocument(InputStream in) throws TransformerException {
        TransformerFactory tFactory = TransformerFactory.newInstance();
        //Custom error listener to minimize output to console
        ErrorListener errorListener = new DefaultErrorListener(log);
        tFactory.setErrorListener(errorListener);
        Transformer transformer = tFactory.newTransformer();
        transformer.setErrorListener(errorListener);
        Source source = new StreamSource(in);
        DOMResult res = new DOMResult();
        transformer.transform(source, res);

        Document doc = (Document)res.getNode();
        return doc;
    }

}
