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

/* $Id: EasyGenerationContentHandlerProxy.java 1297404 2012-03-06 10:17:54Z vhennebert $ */

package embedding.tools;

//SAX
import org.xml.sax.ContentHandler;
import org.xml.sax.Locator;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;

/**
 * This class is an implementation of ContentHandler which acts as a proxy to
 * another ContentHandler and has the purpose to provide a few handy methods
 * that make life easier when generating SAX events.
 * <br>
 * Note: This class is only useful for simple cases with no namespaces.
 */

public class EasyGenerationContentHandlerProxy implements ContentHandler {

    /** An empty Attributes object used when no attributes are needed. */
    public static final Attributes EMPTY_ATTS = new AttributesImpl();

    private ContentHandler target;


    /**
     * Main constructor.
     * @param forwardTo ContentHandler to forward the SAX event to.
     */
    public EasyGenerationContentHandlerProxy(ContentHandler forwardTo) {
        this.target = forwardTo;
    }


    /**
     * Sends the notification of the beginning of an element.
     * @param name Name for the element.
     * @throws SAXException Any SAX exception, possibly wrapping another exception.
     */
    public void startElement(String name) throws SAXException {
        startElement(name, EMPTY_ATTS);
    }


    /**
     * Sends the notification of the beginning of an element.
     * @param name Name for the element.
     * @param atts The attributes attached to the element. If there are no
     * attributes, it shall be an empty Attributes object.
     * @throws SAXException Any SAX exception, possibly wrapping another exception.
     */
    public void startElement(String name, Attributes atts) throws SAXException {
        startElement(null, name, name, atts);
    }


    /**
     * Send a String of character data.
     * @param s The content String
     * @throws SAXException Any SAX exception, possibly wrapping another exception.
     */
    public void characters(String s) throws SAXException {
        target.characters(s.toCharArray(), 0, s.length());
    }


    /**
     * Send the notification of the end of an element.
     * @param name Name for the element.
     * @throws SAXException Any SAX exception, possibly wrapping another exception.
     */
    public void endElement(String name) throws SAXException {
        endElement(null, name, name);
    }


    /**
     * Sends notifications for a whole element with some String content.
     * @param name Name for the element.
     * @param value Content of the element.
     * @throws SAXException Any SAX exception, possibly wrapping another exception.
     */
    public void element(String name, String value) throws SAXException {
        element(name, value, EMPTY_ATTS);
    }


    /**
     * Sends notifications for a whole element with some String content.
     * @param name Name for the element.
     * @param value Content of the element.
     * @param atts The attributes attached to the element. If there are no
     * attributes, it shall be an empty Attributes object.
     * @throws SAXException Any SAX exception, possibly wrapping another exception.
     */
    public void element(String name, String value, Attributes atts) throws SAXException {
        startElement(name, atts);
        if (value != null) {
            characters(value.toCharArray(), 0, value.length());
        }
        endElement(name);
    }

    /* =========== ContentHandler interface =========== */

    /**
     * @see org.xml.sax.ContentHandler#setDocumentLocator(Locator)
     */
    public void setDocumentLocator(Locator locator) {
        target.setDocumentLocator(locator);
    }


    /**
     * @see org.xml.sax.ContentHandler#startDocument()
     */
    public void startDocument() throws SAXException {
        target.startDocument();
    }


    /**
     * @see org.xml.sax.ContentHandler#endDocument()
     */
    public void endDocument() throws SAXException {
        target.endDocument();
    }


    /**
     * @see org.xml.sax.ContentHandler#startPrefixMapping(String, String)
     */
    public void startPrefixMapping(String prefix, String uri) throws SAXException {
        target.startPrefixMapping(prefix, uri);
    }


    /**
     * @see org.xml.sax.ContentHandler#endPrefixMapping(String)
     */
    public void endPrefixMapping(String prefix) throws SAXException {
        target.endPrefixMapping(prefix);
    }


    /**
     * @see org.xml.sax.ContentHandler#startElement(String, String, String, Attributes)
     */
    public void startElement(String namespaceURI, String localName,
                        String qName, Attributes atts) throws SAXException {
        target.startElement(namespaceURI, localName, qName, atts);
    }


    /**
     * @see org.xml.sax.ContentHandler#endElement(String, String, String)
     */
    public void endElement(String namespaceURI, String localName, String qName)
                                                        throws SAXException {
        target.endElement(namespaceURI, localName, qName);
    }


    /**
     * @see org.xml.sax.ContentHandler#characters(char[], int, int)
     */
    public void characters(char[] ch, int start, int length) throws SAXException {
        target.characters(ch, start, length);
    }


    /**
     * @see org.xml.sax.ContentHandler#ignorableWhitespace(char[], int, int)
     */
    public void ignorableWhitespace(char[] ch, int start, int length) throws SAXException {
        target.ignorableWhitespace(ch, start, length);
    }


    /**
     * @see org.xml.sax.ContentHandler#processingInstruction(String, String)
     */
    public void processingInstruction(String target, String data) throws SAXException {
        this.target.processingInstruction(target, data);
    }


    /**
     * @see org.xml.sax.ContentHandler#skippedEntity(String)
     */
    public void skippedEntity(String name) throws SAXException {
        target.skippedEntity(name);
    }

}
