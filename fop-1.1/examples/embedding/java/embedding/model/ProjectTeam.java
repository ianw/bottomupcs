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

/* $Id: ProjectTeam.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package embedding.model;

import java.util.List;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;

/**
 * This bean represents a ProjectTeam.
 */
public class ProjectTeam {

    private String projectName;
    private List members = new java.util.ArrayList();


    /**
     * Returns a list of project members.
     * @return List a list of ProjectMember objects
     */
    public List getMembers() {
        return this.members;
    }


    /**
     * Adds a ProjectMember to this project team.
     * @param member the member to add
     */
    public void addMember(ProjectMember member) {
        this.members.add(member);
    }


    /**
     * Returns the name of the project
     * @return String the name of the project
     */
    public String getProjectName() {
        return projectName;
    }


    /**
     * Sets the name of the project.
     * @param projectName the project name to set
     */
    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }


    /**
     * Resturns a Source object for this object so it can be used as input for
     * a JAXP transformation.
     * @return Source The Source object
     */
    public Source getSourceForProjectTeam() {
        return new SAXSource(new ProjectTeamXMLReader(),
                new ProjectTeamInputSource(this));
    }


}
