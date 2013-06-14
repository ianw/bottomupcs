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

/* $Id: AbstractObjectReader.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package embedding.tools;

//Java
import java.io.IOException;
import java.util.Map;

//SAX
import org.xml.sax.SAXException;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import org.xml.sax.ContentHandler;
import org.xml.sax.DTDHandler;
import org.xml.sax.ErrorHandler;
import org.xml.sax.EntityResolver;

/**
 * This class can be used as base class for XMLReaders that generate SAX
 * events from Java objects.
 */

public abstract class AbstractObjectReader implements XMLReader {

    private static final String NAMESPACES =
        "http://xml.org/sax/features/namespaces";
    private static final String NS_PREFIXES =
        "http://xml.org/sax/features/namespace-prefixes";

    private Map features = new java.util.HashMap();
    private ContentHandler orgHandler;

    /** Proxy for easy SAX event generation */
    protected EasyGenerationContentHandlerProxy handler;
    /** Error handler */
    protected ErrorHandler errorHandler;


    /**
     * Constructor for the AbstractObjectReader object
     */
    public AbstractObjectReader() {
        setFeature(NAMESPACES, false);
        setFeature(NS_PREFIXES, false);
    }

    /* ============ XMLReader interface ============ */

    /**
     * @see org.xml.sax.XMLReader#getContentHandler()
     */
    public ContentHandler getContentHandler() {
        return this.orgHandler;
    }

    /**
     * @see org.xml.sax.XMLReader#setContentHandler(ContentHandler)
     */
    public void setContentHandler(ContentHandler handler) {
        this.orgHandler = handler;
        this.handler = new EasyGenerationContentHandlerProxy(handler);
    }

    /**
     * @see org.xml.sax.XMLReader#getErrorHandler()
     */
    public ErrorHandler getErrorHandler() {
        return this.errorHandler;
    }

    /**
     * @see org.xml.sax.XMLReader#setErrorHandler(ErrorHandler)
     */
    public void setErrorHandler(ErrorHandler handler) {
        this.errorHandler = handler;
    }

    /**
     * @see org.xml.sax.XMLReader#getDTDHandler()
     */
    public DTDHandler getDTDHandler() {
        return null;
    }

    /**
     * @see org.xml.sax.XMLReader#setDTDHandler(DTDHandler)
     */
    public void setDTDHandler(DTDHandler handler) {
    }

    /**
     * @see org.xml.sax.XMLReader#getEntityResolver()
     */
    public EntityResolver getEntityResolver() {
        return null;
    }

    /**
     * @see org.xml.sax.XMLReader#setEntityResolver(EntityResolver)
     */
    public void setEntityResolver(EntityResolver resolver) {
    }

    /**
     * @see org.xml.sax.XMLReader#getProperty(String)
     */
    public Object getProperty(java.lang.String name) {
        return null;
    }

    /**
     * @see org.xml.sax.XMLReader#setProperty(String, Object)
     */
    public void setProperty(java.lang.String name, java.lang.Object value) {
    }

    /**
     * @see org.xml.sax.XMLReader#getFeature(String)
     */
    public boolean getFeature(java.lang.String name) {
        return ((Boolean) features.get(name)).booleanValue();
    }

    /**
     * Returns true if the NAMESPACES feature is enabled.
     * @return boolean true if enabled
     */
    protected boolean isNamespaces() {
        return getFeature(NAMESPACES);
    }

    /**
     * Returns true if the MS_PREFIXES feature is enabled.
     * @return boolean true if enabled
     */
    protected boolean isNamespacePrefixes() {
        return getFeature(NS_PREFIXES);
    }

    /**
     * @see org.xml.sax.XMLReader#setFeature(String, boolean)
     */
    public void setFeature(java.lang.String name, boolean value) {
        this.features.put(name, new Boolean(value));
    }

    /**
     * @see org.xml.sax.XMLReader#parse(String)
     */
    public void parse(String systemId) throws IOException, SAXException {
        throw new SAXException(
            this.getClass().getName()
                + " cannot be used with system identifiers (URIs)");
    }

    /**
     * @see org.xml.sax.XMLReader#parse(InputSource)
     */
    public abstract void parse(InputSource input)
        throws IOException, SAXException;

}
