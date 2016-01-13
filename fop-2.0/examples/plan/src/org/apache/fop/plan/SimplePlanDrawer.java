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

/* $Id: SimplePlanDrawer.java 985571 2010-08-14 19:28:26Z jeremias $ */

package org.apache.fop.plan;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import org.apache.batik.dom.svg.SVGDOMImplementation;

import org.apache.fop.svg.SVGUtilities;

/**
 * Simple plan drawer implementation.
 */
public class SimplePlanDrawer implements PlanDrawer {

    private static final String SVG_NAMESPACE = SVGDOMImplementation.SVG_NAMESPACE_URI;

    private float fontSize;
    private HashMap hints;
    private java.awt.Font font = null;
    private boolean bord = false;
    private float lSpace = 15;
    private float width;
    private float height;
    private float topEdge;
    private float rightEdge;

    private String[] colours;
    private String[] darkcolours;

    private Date startDate;
    private Date endDate;

    /**
     * Sets the start date.
     * @param sd start date
     */
    public void setStartDate(Date sd) {
        startDate = sd;
    }

    /**
     * Sets the end date.
     * @param ed end date
     */
    public void setEndDate(Date ed) {
        endDate = ed;
    }

    /**
     * @see org.apache.fop.plan.PlanDrawer#createDocument(EventList, float, float, HashMap)
     */
    public Document createDocument(EventList data, float w, float h,
                                   HashMap hints) {
        this.width = w;
        this.height = h;
        this.hints = hints;
        fontSize = ((Float) hints.get(PlanHints.FONT_SIZE)).floatValue();
        bord = ((Boolean) hints.get(PlanHints.PLAN_BORDER)).booleanValue();

        String title = "";

        DOMImplementation impl
            = SVGDOMImplementation.getDOMImplementation();
        Document doc = impl.createDocument(SVG_NAMESPACE, "svg", null);

        Element svgRoot = doc.getDocumentElement();
        svgRoot.setAttributeNS(null, "width", Float.toString(width));
        svgRoot.setAttributeNS(null, "height", Float.toString(height));
        svgRoot.setAttributeNS(null, "viewBox",
                "0 0 " + Float.toString(width) + " " + Float.toString(height));
        svgRoot.setAttributeNS(null, "style",
                               "font-size:" + 8
                                   + ";font-family:"
                                   + hints.get(PlanHints.FONT_FAMILY));

        font = new java.awt.Font((String)hints.get(PlanHints.FONT_FAMILY),
                                  java.awt.Font.PLAIN, (int)fontSize);

        if (bord) {
            Element border
                = SVGUtilities.createRect(doc, 0, 0, width, height);
            border.setAttributeNS(null, "style", "stroke:black;fill:none");
            svgRoot.appendChild(border);
        }

        float strwidth = SVGUtilities.getStringWidth(title, font);

        Element text;
        float pos = (float)(80 - strwidth / 2.0);
        if (pos < 5) {
            pos = 5;
        }
        text = SVGUtilities.createText(doc, pos, 18, title);
        text.setAttributeNS(null, "style", "font-size:14");
        svgRoot.appendChild(text);

        topEdge = SVGUtilities.getStringHeight(title, font) + 5;

        // add the actual pie chart
        addPlan(doc, svgRoot, data);
        //addLegend(doc, svgRoot, data);

        return doc;
    }

    protected void addPlan(Document doc, Element svgRoot, EventList data) {
        Date currentDate = new Date();

        Date lastWeek = startDate;
        Date future = endDate;
        Calendar lw = Calendar.getInstance();
        if (lastWeek == null || future == null) {
            int dow = lw.get(Calendar.DAY_OF_WEEK);
            lw.add(Calendar.DATE, -dow - 6);
            lastWeek = lw.getTime();
            lw.add(Calendar.DATE, 5 * 7);
            future = lw.getTime();
        }
        long totalDays = (long)((future.getTime() - lastWeek.getTime() + 43200000) / 86400000);
        lw.setTime(lastWeek);
        int startDay = lw.get(Calendar.DAY_OF_WEEK);

        float graphTop = topEdge;
        Element g;
        Element line;
        line = SVGUtilities.createLine(doc, 0, topEdge, width, topEdge);
        line.setAttributeNS(null, "style", "fill:none;stroke:black");
        svgRoot.appendChild(line);

        Element clip1 = SVGUtilities.createClip(doc,
                SVGUtilities.createPath(doc,
                    "m0 0l126 0l0 " + height + "l-126 0z"), "clip1");
        Element clip2 = SVGUtilities.createClip(doc,
                SVGUtilities.createPath(doc,
                    "m130 0l66 0l0 " + height + "l-66 0z"), "clip2");
        Element clip3 = SVGUtilities.createClip(doc,
                SVGUtilities.createPath(doc,
                    "m200 0l" + (width - 200) + " 0l0 " + height + "l-"
                        + (width - 200) + " 0z"), "clip3");
        svgRoot.appendChild(clip1);
        svgRoot.appendChild(clip2);
        svgRoot.appendChild(clip3);

        DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);
        Element text;
        text = SVGUtilities.createText(doc, 201, topEdge - 1,
                                       df.format(lastWeek));
        svgRoot.appendChild(text);

        text = SVGUtilities.createText(doc, width, topEdge - 1,
                                       df.format(future));
        text.setAttributeNS(null, "text-anchor", "end");
        svgRoot.appendChild(text);

        line = SVGUtilities.createLine(doc, 128, topEdge, 128, height);
        line.setAttributeNS(null, "style", "fill:none;stroke:rgb(150,150,150)");
        svgRoot.appendChild(line);
        int offset = 0;
        for (int count = startDay; count < startDay + totalDays - 1; count++) {
            offset++;
            if (count % 7 == 0 || count % 7 == 1) {
                Element rect = SVGUtilities.createRect(doc,
                    200 + (offset - 1) * (width - 200) / (totalDays - 2),
                    (float)(topEdge + 0.5),
                    (width - 200) / (totalDays - 3),
                    height - 1 - topEdge);
                rect.setAttributeNS(null, "style", "stroke:none;fill:rgb(230,230,230)");
                svgRoot.appendChild(rect);
            }
            line = SVGUtilities.createLine(doc,
                                           200 + (offset - 1) * (width - 200) / (totalDays - 2),
                                           (float)(topEdge + 0.5),
                                           200 + (offset - 1) * (width - 200) / (totalDays - 2),
                                           (float)(height - 0.5));
            line.setAttributeNS(null, "style", "fill:none;stroke:rgb(200,200,200)");
            svgRoot.appendChild(line);
        }


        for (int count = 0; count < data.getSize(); count++) {
            GroupInfo gi = data.getGroupInfo(count);
            g = SVGUtilities.createG(doc);
            text = SVGUtilities.createText(doc, 1, topEdge + 12,
                                           gi.getName());
            text.setAttributeNS(null, "style", "clip-path:url(#clip1)");
            g.appendChild(text);
            if (count > 0) {
                line = SVGUtilities.createLine(doc, 0, topEdge + 2,
                                               width, topEdge + 2);
                line.setAttributeNS(null, "style", "fill:none;stroke:rgb(100,100,100)");
                g.appendChild(line);
            }

            float lastTop = topEdge;
            topEdge += 14;
            boolean showing = false;
            for (int count1 = 0; count1 < gi.getSize(); count1++) {
                ActionInfo act = gi.getActionInfo(count1);
                String name = act.getOwner();
                String label = act.getLabel();
                text = SVGUtilities.createText(doc, 8, topEdge + 12, label);
                text.setAttributeNS(null, "style", "clip-path:url(#clip1)");
                g.appendChild(text);

                text = SVGUtilities.createText(doc, 130, topEdge + 12,
                                               name);
                text.setAttributeNS(null, "style", "clip-path:url(#clip2)");
                g.appendChild(text);
                int type = act.getType();
                Date start = act.getStartDate();
                Date end = act.getEndDate();
                if (end.after(lastWeek) && start.before(future)) {
                    showing = true;
                    int left = 200;
                    int right = 500;

                    int daysToStart = (int)((start.getTime()
                                - lastWeek.getTime() + 43200000) / 86400000);
                    int days = (int)((end.getTime() - start.getTime()
                                + 43200000) / 86400000);
                    int daysFromEnd
                        = (int)((future.getTime() - end.getTime()
                            + 43200000) / 86400000);
                    Element taskGraphic;
                    switch (type) {
                        case ActionInfo.TASK:
                            taskGraphic = SVGUtilities.createRect(doc,
                                left + daysToStart * 300 / (totalDays - 2),
                                topEdge + 2, days * 300 / (totalDays - 2), 10);
                            taskGraphic.setAttributeNS(null,
                                "style",
                                "stroke:black;fill:blue;stroke-width:1;clip-path:url(#clip3)");
                            g.appendChild(taskGraphic);
                            break;
                        case ActionInfo.MILESTONE:
                            taskGraphic = SVGUtilities.createPath(doc,
                                "m " + (left
                                    + daysToStart * 300 / (totalDays - 2) - 6)
                                    + " " + (topEdge + 6) + "l6 6l6-6l-6-6z");
                            taskGraphic.setAttributeNS(null,
                                "style",
                                "stroke:black;fill:black;stroke-width:1;clip-path:url(#clip3)");
                            g.appendChild(taskGraphic);
                            text = SVGUtilities.createText(doc,
                                left + daysToStart * 300 / (totalDays - 2) + 8,
                                topEdge + 9, df.format(start));
                            g.appendChild(text);

                            break;
                        case ActionInfo.GROUPING:
                            taskGraphic = SVGUtilities.createPath(doc,
                                "m " + (left
                                    + daysToStart * 300 / (totalDays - 2) - 6)
                                    + " " + (topEdge + 6) + "l6 -6l"
                                    + (days * 300 / (totalDays - 2))
                                    + " 0l6 6l-6 6l-4-4l"
                                    + -(days * 300 / (totalDays - 2) - 8)
                                    + " 0l-4 4l-6-6z");
                            taskGraphic.setAttributeNS(null,
                                "style",
                                "stroke:black;fill:black;stroke-width:1;clip-path:url(#clip3)");
                            g.appendChild(taskGraphic);
                            break;
                        default:
                            break;
                    }
                }

                topEdge += 14;
            }
            if (showing) {
                svgRoot.appendChild(g);
            } else {
                topEdge = lastTop;
            }
        }
        int currentDays
            = (int)((currentDate.getTime() - lastWeek.getTime()
                + 43200000) / 86400000);

        text = SVGUtilities.createText(doc,
                                       (float)(200 + (currentDays + 0.5) * 300 / 35),
                                       graphTop - 1, df.format(currentDate));
        text.setAttributeNS(null, "text-anchor", "middle");
        text.setAttributeNS(null, "style", "stroke:rgb(100,100,100)");
        svgRoot.appendChild(text);

        line = SVGUtilities.createLine(doc,
                                       (float)(200 + (currentDays + 0.5) * 300 / 35), graphTop,
                                       (float)(200 + (currentDays + 0.5) * 300 / 35), height);
        line.setAttributeNS(null, "style", "fill:none;stroke:rgb(200,50,50);stroke-dasharray:5,5");
        svgRoot.appendChild(line);


    }
}
