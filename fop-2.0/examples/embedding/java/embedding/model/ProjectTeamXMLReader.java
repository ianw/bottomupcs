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

/* $Id: ProjectTeamXMLReader.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package embedding.model;

//Java
import java.util.Iterator;
import java.io.IOException;

//SAX
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import embedding.tools.AbstractObjectReader;

/**
 * XMLReader implementation for the ProjectTeam class. This class is used to
 * generate SAX events from the ProjectTeam class.
 */
public class ProjectTeamXMLReader extends AbstractObjectReader {

    /**
     * @see org.xml.sax.XMLReader#parse(InputSource)
     */
    public void parse(InputSource input) throws IOException, SAXException {
        if (input instanceof ProjectTeamInputSource) {
            parse(((ProjectTeamInputSource)input).getProjectTeam());
        } else {
            throw new SAXException("Unsupported InputSource specified. "
                    + "Must be a ProjectTeamInputSource");
        }
    }


    /**
     * Starts parsing the ProjectTeam object.
     * @param projectTeam The object to parse
     * @throws SAXException In case of a problem during SAX event generation
     */
    public void parse(ProjectTeam projectTeam) throws SAXException {
        if (projectTeam == null) {
            throw new NullPointerException("Parameter projectTeam must not be null");
        }
        if (handler == null) {
            throw new IllegalStateException("ContentHandler not set");
        }

        //Start the document
        handler.startDocument();

        //Generate SAX events for the ProjectTeam
        generateFor(projectTeam);

        //End the document
        handler.endDocument();
    }


    /**
     * Generates SAX events for a ProjectTeam object.
     * @param projectTeam ProjectTeam object to use
     * @throws SAXException In case of a problem during SAX event generation
     */
    protected void generateFor(ProjectTeam projectTeam) throws SAXException {
        if (projectTeam == null) {
            throw new NullPointerException("Parameter projectTeam must not be null");
        }
        if (handler == null) {
            throw new IllegalStateException("ContentHandler not set");
        }

        handler.startElement("projectteam");
        handler.element("projectname", projectTeam.getProjectName());
        Iterator i = projectTeam.getMembers().iterator();
        while (i.hasNext()) {
            ProjectMember member = (ProjectMember)i.next();
            generateFor(member);
        }
        handler.endElement("projectteam");
    }

    /**
     * Generates SAX events for a ProjectMember object.
     * @param projectMember ProjectMember object to use
     * @throws SAXException In case of a problem during SAX event generation
     */
    protected void generateFor(ProjectMember projectMember) throws SAXException {
        if (projectMember == null) {
            throw new NullPointerException("Parameter projectMember must not be null");
        }
        if (handler == null) {
            throw new IllegalStateException("ContentHandler not set");
        }

        handler.startElement("member");
        handler.element("name", projectMember.getName());
        handler.element("function", projectMember.getFunction());
        handler.element("email", projectMember.getEmail());
        handler.endElement("member");
    }

}
