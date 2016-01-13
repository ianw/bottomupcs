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

/* $Id: PlanRenderer.java 985571 2010-08-14 19:28:26Z jeremias $ */

package org.apache.fop.plan;


import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.StringTokenizer;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import org.apache.batik.dom.svg.SVGDOMImplementation;

public class PlanRenderer {

    private static final String SVG_NAMESPACE = SVGDOMImplementation.SVG_NAMESPACE_URI;

    private String fontFamily = "sansserif";
    private float fontSize = 12;
    private String type = "";
    private String lang = "";
    private String country = "";
    private String variant = "";
    private float width;
    private float height;
    private float topEdge;
    private float rightEdge;
    private HashMap hints = new HashMap();

    private String[] colours;
    private String[] darkcolours;

    public void setFontInfo(String fam, float si) {
        fontFamily = fam;
        fontSize = si;
    }

    public float getWidth() {
        return width;
    }

    public float getHeight() {
        return height;
    }

    protected float toFloat(String str) {
        return Float.parseFloat(str);
    }

    public Document createSVGDocument(Document planDoc) {

        Element svgRoot = planDoc.getDocumentElement();

        width = toFloat(svgRoot.getAttribute("width"));
        height = toFloat(svgRoot.getAttribute("height"));
        type = svgRoot.getAttribute("type");
        lang = svgRoot.getAttribute("lang");
        country = svgRoot.getAttribute("country");
        variant = svgRoot.getAttribute("variant");
        String style = svgRoot.getAttribute("style");
        parseStyle(style);

        Locale locale = new Locale(lang, country == null ? "" : country,
                                   variant == null ? "" : variant);

        String start = svgRoot.getAttribute("start");
        String end = svgRoot.getAttribute("end");
        Date sd = getDate(start, locale);
        Date ed = getDate(end, locale);

        String title = "";
        EventList data = null;
        NodeList childs = svgRoot.getChildNodes();
        for (int i = 0; i < childs.getLength(); i++) {
            Node obj = childs.item(i);
            String nname = obj.getNodeName();
            if (nname.equals("title")) {
                title = ((Element) obj).getFirstChild().getNodeValue();
            } else if (nname.equals("events")) {
                data = getEvents((Element) obj, locale);
            }
        }

        SimplePlanDrawer planDrawer = new SimplePlanDrawer();
        planDrawer.setStartDate(sd);
        planDrawer.setEndDate(ed);
        hints.put(PlanHints.FONT_FAMILY, fontFamily);
        hints.put(PlanHints.FONT_SIZE, new Float(fontSize));
        hints.put(PlanHints.LOCALE, locale);
        Document doc
            = planDrawer.createDocument(data, width, height, hints);
        return doc;
    }

    protected void parseStyle(String style) {
        hints.put(PlanHints.PLAN_BORDER, new Boolean(true));
        hints.put(PlanHints.FONT_FAMILY, fontFamily);
        hints.put(PlanHints.FONT_SIZE, new Float(fontSize));
        hints.put(PlanHints.LABEL_FONT_SIZE, new Float(fontSize));
        hints.put(PlanHints.LABEL_FONT, fontFamily);
        hints.put(PlanHints.LABEL_TYPE, "textOnly");

        StringTokenizer st = new StringTokenizer(style, ";");
        while (st.hasMoreTokens()) {
            String pair = st.nextToken().trim();
            int index = pair.indexOf(":");
            String name = pair.substring(0, index).trim();
            String val = pair.substring(index + 1).trim();
            if (name.equals(PlanHints.PLAN_BORDER)) {
                hints.put(name, Boolean.valueOf(val));
            } else if (name.equals(PlanHints.FONT_SIZE)) {
                hints.put(name, Float.valueOf(val));
            } else if (name.equals(PlanHints.LABEL_FONT_SIZE)) {
                hints.put(name, Float.valueOf(val));
            } else {
                hints.put(name, val);
            }
        }
    }

    public ActionInfo getActionInfo(Element ele, Locale locale) {
        String t = ele.getAttribute("type");

        NodeList childs = ele.getChildNodes();
        ActionInfo data = new ActionInfo();
        if (t.equals("milestone")) {
            data.setType(ActionInfo.MILESTONE);
        } else if (t.equals("task")) {
            data.setType(ActionInfo.TASK);
        } else if (t.equals("grouping")) {
            data.setType(ActionInfo.GROUPING);
        } else {
            throw new IllegalArgumentException("Unknown action type: " + t);
        }

        for (int i = 0; i < childs.getLength(); i++) {
            Node obj = childs.item(i);
            String nname = obj.getNodeName();
            if (nname.equals("label")) {
                String dat = ((Element) obj).getFirstChild().getNodeValue();
                data.setLabel(dat);
            } else if (nname.equals("owner")) {
                String dat = ((Element) obj).getFirstChild().getNodeValue();
                data.setOwner(dat);
            } else if (nname.equals("startdate")) {
                Date dat = getDate((Element) obj, locale);
                data.setStartDate(dat);
            } else if (nname.equals("enddate")) {
                Date dat = getDate((Element) obj, locale);
                data.setEndDate(dat);
            }
        }
        return data;
    }

    public EventList getEvents(Element ele, Locale locale) {
        EventList data = new EventList();
        NodeList childs = ele.getChildNodes();
        for (int i = 0; i < childs.getLength(); i++) {
            Node obj = childs.item(i);
            if (obj.getNodeName().equals("group")) {
                GroupInfo dat = getGroupInfo((Element) obj, locale);
                data.addGroupInfo(dat);
            }
        }
        return data;
    }

    public GroupInfo getGroupInfo(Element ele, Locale locale) {
        NodeList childs = ele.getChildNodes();
        GroupInfo data = new GroupInfo(ele.getAttribute("name"));
        for (int i = 0; i < childs.getLength(); i++) {
            Node obj = childs.item(i);
            if (obj.getNodeName().equals("action")) {
                ActionInfo dat = getActionInfo((Element) obj, locale);
                data.addActionInfo(dat);
            }
        }
        return data;
    }

    public Date getDate(Element ele, Locale locale) {
        String label = ele.getFirstChild().getNodeValue();
        return getDate(label, locale);
    }

    public Date getDate(String label, Locale locale) {
        Calendar cal = Calendar.getInstance(locale);

        String str;
        str = label.substring(0, 4);
        int intVal = Integer.valueOf(str).intValue();
        cal.set(Calendar.YEAR, intVal);

        str = label.substring(4, 6);
        intVal = Integer.valueOf(str).intValue();
        cal.set(Calendar.MONTH, intVal - 1);

        str = label.substring(6, 8);
        intVal = Integer.valueOf(str).intValue();
        cal.set(Calendar.DATE, intVal);
        return cal.getTime();
    }
}

