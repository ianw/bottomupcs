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

/* $Id: PlanElement.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package org.apache.fop.plan;

import java.awt.geom.Point2D;

import org.w3c.dom.Document;

import org.xml.sax.Attributes;
import org.xml.sax.Locator;

import org.apache.fop.apps.FOPException;
import org.apache.fop.fo.FONode;
import org.apache.fop.fo.PropertyList;

/**
 * This class defines the plan element.
 */
public class PlanElement extends PlanObj {

    private Document svgDoc = null;
    private float width;
    private float height;
    private boolean converted;

    /**
     * @see org.apache.fop.fo.FONode#FONode(FONode)
     */
    public PlanElement(FONode parent) {
        super(parent);
    }

    /** {@inheritDoc} */
    public void processNode(String elementName, Locator locator,
                            Attributes attlist, PropertyList propertyList)
        throws FOPException {
        super.processNode(elementName, locator, attlist, propertyList);
        createBasicDocument();
    }

    /**
     * Converts the element to SVG.
     */
    public void convertToSVG() {
        try {
            if (!converted) {
                converted = true;
                PlanRenderer pr = new PlanRenderer();
                pr.setFontInfo("Helvetica", 12);
                svgDoc = pr.createSVGDocument(doc);
                width = pr.getWidth();
                height = pr.getHeight();

                doc = svgDoc;
            }
        } catch (Throwable t) {
            getLogger().error("Could not convert Plan to SVG", t);
            width = 0;
            height = 0;
        }

    }

    /** {@inheritDoc} */
    public Document getDOMDocument() {
        convertToSVG();
        return doc;
    }

    /** {@inheritDoc} */
    public String getNamespaceURI() {
        if (svgDoc == null) {
            return PlanElementMapping.NAMESPACE;
        }
        return "http://www.w3.org/2000/svg";
    }

    /** {@inheritDoc} */
    public Point2D getDimension(Point2D view) {
        convertToSVG();
        return new Point2D.Float(width, height);
    }
}

