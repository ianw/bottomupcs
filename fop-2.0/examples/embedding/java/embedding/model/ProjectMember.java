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

/* $Id: ProjectMember.java 679326 2008-07-24 09:35:34Z vhennebert $ */

package embedding.model;

/**
 * This bean represents a project member.
 */
public class ProjectMember {

    private String name;
    private String function;
    private String email;


    /**
     * Default no-parameter constructor.
     */
    public ProjectMember() {
    }


    /**
     * Convenience constructor.
     * @param name name of the project member
     * @param function function in the team
     * @param email email address
     */
    public ProjectMember(String name, String function, String email) {
        setName(name);
        setFunction(function);
        setEmail(email);
    }

    /**
     * Returns the name.
     * @return String the name
     */
    public String getName() {
        return name;
    }


    /**
     * Returns the function.
     * @return String the function
     */
    public String getFunction() {
        return function;
    }


    /**
     * Returns the email address.
     * @return String the email address
     */
    public String getEmail() {
        return email;
    }


    /**
     * Sets the name.
     * @param name The name to set
     */
    public void setName(String name) {
        this.name = name;
    }


    /**
     * Sets the function.
     * @param function The function to set
     */
    public void setFunction(String function) {
        this.function = function;
    }


    /**
     * Sets the email address.
     * @param email The email address to set
     */
    public void setEmail(String email) {
        this.email = email;
    }

}
